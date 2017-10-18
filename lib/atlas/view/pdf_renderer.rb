# frozen_string_literal: true

module Atlas
  module View
    class PdfRenderer
      # DEPRECATED: Use PdfRenderer.render
      def self.to_pdf(template)
        Atlas::View::PdfRenderer.new.render(template)
      end

      def self.render(template, page_size: 'Letter', **params)
        PDFKit.new(template, page_size: page_size, **params).to_pdf
      end

      # DEPRECATED: Use PdfRenderer.render
      # :reek:UtilityFunction
      def render(template, **params)
        PdfRenderer.render(template, page_size: 'Letter', **params)
      end
    end
  end
end
