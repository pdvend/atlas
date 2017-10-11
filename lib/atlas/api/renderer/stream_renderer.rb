module Atlas
  module Api
    module Renderer
      class StreamRenderer < JsonRenderer
        def headers
          super.merge('Content-Type' => 'application/json')
        end

        def body
          return error_from(service_response).to_json unless service_response.success?
          data = body_data
          return data if data.is_a?(Enumerator)
          Enumerator.new { |yielder| yielder << super }
        end
      end
    end
  end
end
