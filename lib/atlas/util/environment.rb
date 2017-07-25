module Atlas
  module Util
    module Environment
      @env = (ENV['APPLICATION_ENV'] || '').to_sym

      module_function

      def production?
        is?(:production)
      end

      def test?
        is?(:test)
      end

      def development?
        is?(:dev) || is?(:development)
      end

      def is?(env)
        @env == env
      end
    end
  end
end
