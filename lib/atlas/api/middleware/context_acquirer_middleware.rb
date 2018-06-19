# frozen_string_literal: true

module Atlas
  module API
    module Middleware
      class ContextAcquirerMiddleware
        def initialize(app, component: nil)
          @app = app
          @component = component
        end

        def call(env)
          request_context = env[:request_context]

          if request_context
            request_context.component = @component if @component
            request_context.account_id = env[:account_id]
            request_context.authentication_type = env[:authentication_type]
            request_context.user = env[:user]
          end

          @app.call(env)
        end
      end
    end
  end
end
