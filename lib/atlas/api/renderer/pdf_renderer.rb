module Atlas
  module Api
    module Renderer
      class PdfRenderer < BaseRenderer
        def headers
          super.merge('Content-Type' => 'application/xml')
        end

        def body
          super || body_data.force_encoding('utf-8')
        end
      end
    end
  end
end
