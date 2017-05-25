module Atlas
  module View
    class TemplateRenderer < OpenStruct
      def self.from_hash(template, params)
        Atlas::View::TemplateRenderer.new(params).render(template)
      end

      def render(template)
        ERB.new(template).result(binding)
      end
    end
  end
end
