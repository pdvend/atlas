module Atlas
  module Api
    module Renderer
      class XmlRenderer < BaseRenderer
        def headers
          super.merge('Content-Type' => 'application/xml')
        end

        def body
          super || body_data
        end
      end
    end
  end
end
