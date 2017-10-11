module Atlas
  module Api
    module Renderer
      class PdfRenderer < BaseRenderer
        def headers
          filename = service_response.data[:file_name].to_s

          super.merge(
            'Content-Type' => 'application/zip',
            'Content-Disposition' => "attachment; file_name=\"#{filename}\""
          )
        end

        def body
          super || body_data
        end
      end
    end
  end
end
