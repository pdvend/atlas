# frozen_string_literal: true

module Atlas
  module API
    module Renderer
      class PdfRenderer < BaseRenderer
        def headers
          super.merge('Content-Type' => 'application/pdf')
        end

        def body
          super || body_data.force_encoding('utf-8')
        end
      end
    end
  end
end
