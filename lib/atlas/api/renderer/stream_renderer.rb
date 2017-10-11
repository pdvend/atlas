module Atlas
  module API
    module Renderer
      class StreamRenderer < JsonRenderer
        def headers
          base = super
          body_data.is_a?(Enumerator) ? base : base.merge('Content-Type' => 'application/json')
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
