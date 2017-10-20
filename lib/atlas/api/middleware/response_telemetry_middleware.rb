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
          @app.call(env).tap do |response|
            context = env[:request_context]
            emit_event(context, response) if @telemetry_service && context
          end
        end

        private

        BODY_LENGTH = {
          Rack::BodyProxy => ->(body) { body.length },
          # TODO: Do not measure GzipStream body length since it blocks the response
          Rack::Deflater::GzipStream => ->(body) { body.each.map(&:length).reduce(0, &:+) },
          Rack::Chunked::Body => ->(_body) { -1 }
        }.freeze

        BODY_LENGTH_STANDARD = ->(body) { body.lazy.map(&:bytesize).reduce(&:+) }

        def emit_event(context, response)
          data = data_from_response(*response)
          @telemetry_service.execute(context, type: :http_response, data: data)
        end

        def data_from_response(status, _headers, body)
          body_length = BODY_LENGTH.fetch(body.class, BODY_LENGTH_STANDARD)[body]
          { status: status, length: body_length }
        end
      end
    end
  end
end
