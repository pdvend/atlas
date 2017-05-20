module Atlas
  module Util
    module Environment
      @env = (ENV['APPLICATION_ENV'] || '').to_sym

      module_function

      def production?
        @env == :production
      end

      def development?
        !production?
      end
    end
  end
end
