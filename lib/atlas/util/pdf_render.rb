module Atlas
  module Util
    class PdfRender
      def self.to_pdf(template)
        Atlas::Util::PdfRender.new.render(template)
      end

      def render(template)
        kit = PDFKit.new(template, page_size: 'Letter')
        kit.to_pdf
      end
    end
  end
end
