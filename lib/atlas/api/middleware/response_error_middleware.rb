module Atlas
  module API
    module Middleware
      class ResponseErrorMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          if status == 404 || status.between?(500, 599)
            return [status, {}, [error_as_json(status, body)]]
          end
          [status, headers, body]
        end

        private

        def error_as_json(status, body)
          {
            code: status,
            errors: {
              base: body.body
            }
          }.to_json
        end
      end
    end
  end
end
