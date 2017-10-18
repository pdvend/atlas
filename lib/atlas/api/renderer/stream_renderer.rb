module Atlas
  module API
    module Renderer
      class StreamRenderer < JsonRenderer
        def headers
          body_data.is_a?(Enumerator) ? {} : super
        end

        def body
          data = body_data
          return data if data.is_a?(Enumerator)
          Enumerator.new { |yielder| yielder << super }
        end
      end
    end
  end
end
