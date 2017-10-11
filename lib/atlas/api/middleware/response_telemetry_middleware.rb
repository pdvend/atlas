# frozen_string_literal: true

module Atlas
  module API
    module Middleware
      class ResponseTelemetryMiddleware
        TELEMETRY_SERVICE = 'service.telemetry.emit'

        def initialize(app, telemetry_service: nil)
          @app = app
          @telemetry_service = telemetry_service || Atlas::Dependencies[TELEMETRY_SERVICE]
        end

        def call(env)
          response = @app.call(env)
          context = env[:request_context]
          emit_event(context, response) if @telemetry_service && context
          response
        end

        private

        def body_length(body)
          case body
          when Rack::BodyProxy
            body.length
          when Rack::Deflater::GzipStream
            gzip_stream_length(body)
          when Rack::Chunked::Body
            -1 # Unknown
          else
            body.lazy.map(&:bytesize).reduce(&:+)
          end
        end

        def gzip_stream_length(stream)
          size = 0
          stream.each { |part| size += part.length }
          size
        end

        def emit_event(context, response)
          body = response.last
          data = { status: response.first, length: body_length(body) }
          @telemetry_service.execute(context, type: :http_response, data: data)
        end
      end
    end
  end
end
