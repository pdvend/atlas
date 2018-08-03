# frozen_string_literal: true

module Atlas
  module API
    module Renderer
      class StreamRenderer < JsonRenderer
        def headers
          super.merge('Content-Encoding' => 'gzip') if service_response.success?
        end

        def body
          return error_from(service_response).to_json unless service_response.success?

          data = body_data
          return data unless data.is_a?(Enumerable)
          lazy_data = data.lazy

          element = nil

          Enumerator.new do |yielder|
            stream = Atlas::Util::GzipYieldStream.new(yielder)
            stream.write('[')

            element = lazy_data.next
            serializer = serializer_class_to(element)

            loop do
              stream.write(serializer.new(element).to_json)
              element = nil
              element = lazy_data.next
              stream.write(',')
            end

          rescue StopIteration
            stream.write(serializer_instance_to(element).to_json) if element
            stream.write(']')
            stream.close
          end
        end
      end
    end
  end
end
