# frozen_string_literal: true

module Atlas
  module API
    module Middleware
      class ResponseTelemetryMiddleware
        def initialize(app, telemetry_service)
          @app = app
          @telemetry_service = telemetry_service
        end

        def call(env)
          begin
            response = @app.call(env)
          rescue Exception => e
            exception = e
          end

          emit_event(env, response, exception) if @telemetry_service
          exception ? raise(exception) : response
        end

        private

        BODY_LENGTH = {
          Rack::BodyProxy => ->(body) { body.length },
          Rack::Deflater::GzipStream => ->(_body) { -1 },
          Rack::Chunked::Body => ->(_body) { -1 }
        }.freeze

        BODY_LENGTH_STANDARD = ->(body) { body.lazy.map(&:bytesize).reduce(&:+) }

        def emit_event(env, response, exception)
          context = env[:request_context]
          return unless context

          @telemetry_service.execute(
            context,
            type: :http_response,
            data: data_from_transaction(env, response, exception)
          )
        end

        def data_from_transaction(env, response, exception)
          {
            **request_keys(env),
            **response_keys(response),
            **exception_keys(exception)
          }
        end

        def request_keys(env)
          url = Rack::Request.new(env).url

          {
            request: "#{env['REQUEST_METHOD']} #{url}",
            params: env['router.params'] || {}
          }
        end

        def response_keys(response)
          if response
            status, _headers, body = response
            body_length = BODY_LENGTH.fetch(body.class, BODY_LENGTH_STANDARD)[body]
          end

          {
            status: status,
            length: body_length,
          }
        end

        def exception_keys(exception)
          return {} unless exception

          {
            exception: {
              class:     exception.class.name,
              message:   exception.message,
              backtrace: exception.backtrace
            }
          }
        end
      end
    end
  end
end
