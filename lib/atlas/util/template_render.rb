module Atlas
  module Util
    class TemplateRender < OpenStruct
      def self.from_hash(template, params)
        Atlas::Util::TemplateRender.new(params).render(template)
      end

      def render(template)
        ERB.new(template).result(binding)
      end
    end
  end
end
