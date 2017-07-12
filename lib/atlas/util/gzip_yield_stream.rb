module Atlas
  module Util
    class GzipYieldStream
      def initialize(yielder)
        @gzip = ::Zlib::GzipWriter.new(YieldStream.new(yielder))
      end

      def write(data)
        return if data.empty?
        @gzip.write(data)
      end

      def set_encoding(*)
        # DO NOTHING
      end

      def close(*)
        @gzip.close
      end
    end
  end
end
