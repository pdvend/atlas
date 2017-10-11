# frozen_string_literal: true

module Atlas
  module API
    module Middleware
      # :reek:TooManyConstants
      class RequestContextMiddleware
        CALLER_HEADER_NAME = 'HTTP_X_TELEMETRY_CALLER'
        TRANSACTION_HEADER_NAME = 'HTTP_X_TELEMETRY_TRANSACTION_ID'
        REMOTE_ADDR_KEY = 'REMOTE_ADDR'
        UNKNOWN_COMPONENT = '[Unknown Component]'
        CALLER_ID_FROM_ENV = ->(env) { env[CALLER_HEADER_NAME] || env[REMOTE_ADDR_KEY] }
        TRANSACTION_ID_FROM_ENV = ->(env) { env[TRANSACTION_HEADER_NAME] || SecureRandom.uuid }

        def initialize(app)
          @app = app
        end

        def call(env)
          initialize_request_context(env)
          @app.call(env)
        end

        private

        def initialize_request_context(env)
          env[:request_context] = Atlas::Service::RequestContext.new(
            time: Time.now.utc,
            component: UNKNOWN_COMPONENT,
            caller: CALLER_ID_FROM_ENV[env],
            transaction_id: TRANSACTION_ID_FROM_ENV[env],
            account_id: nil
          )
        end
      end
    end
  end
end
