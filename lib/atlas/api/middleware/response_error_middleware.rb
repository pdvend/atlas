# frozen_string_literal: true

module Atlas
  module API
    module Middleware
      class ResponseErrorMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          return [status, headers, body] unless IS_ERROR_STATUS[status]
          return [status, {}, [error_as_json(status, body)]]
        end

        private

        IS_ERROR_STATUS = ->(status) { status == 404 || status.between?(500, 599) }

        ERROR_CODES_FROM_STATUS = {
          404 => Enum::ErrorCodes::ROUTE_NOT_FOUND
        }.freeze

        def error_as_json(status, body)
          code = ERROR_CODES_FROM_STATUS.fetch(status, Enum::ErrorCodes::INTERNAL)
          return body.first.to_json if body.is_a?(Array)
          { code: code, message: body.body, errors: {} }.to_json
        end
      end
    end
  end
end
