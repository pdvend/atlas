module Atlas
  module View
    class PdfRenderer
      def self.to_pdf(template)
        Atlas::View::PdfRenderer.new.render(template)
      end

      def render(template, page_size: 'Letter', **params)
        kit = PDFKit.new(template, page_size: page_size, **params)
        kit.to_pdf
      end
    end
  end
end
