# frozen_string_literal: true

module Atlas
  module API
    module Renderer
      class StreamRenderer < JsonRenderer
        def body
          data = body_data
          Enumerator.new do |yielder|
            data.each { |element| yielder << serializer_instance_to(element).to_json }
          end
        end
      end
    end
  end
end
