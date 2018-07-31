# frozen_string_literal: true

module Atlas
  module API
    module Renderer
      class StreamRenderer < JsonRenderer
        def headers
          super.merge('Content-Encoding' => 'gzip')
        end

        def body
          data = body_data

          Enumerator.new do |yielder|
            stream = Atlas::Util::GzipYieldStream.new(yielder)

            data.lazy
                .map(&method(:serializer_instance_to))
                .map(&:to_json)
                .each(&stream.method(:write))

            stream.close
          end
        end
      end
    end
  end
end
