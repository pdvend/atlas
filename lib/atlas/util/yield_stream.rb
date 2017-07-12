module Atlas
  module Util
    class YieldStream
      def initialize(yielder)
        @yielder = yielder
      end

      def write(data)
        return if data.empty?
        yielder << data
      end

      def set_encoding(*)
        # DO NOTHING
      end

      def close(*)
        # DO NOTHING
      end
    end
  end
end
