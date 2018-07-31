# frozen_string_literal: true

module Atlas
  module Util
    class GzipYieldStream
      def initialize(yielder)
        @gzip = ::Zlib::GzipWriter.new(YieldStream.new(yielder))
      end

      def write(data)
        return if data.empty?
        @gzip.write(data)
        @gzip.flush
      end

      # rubocop:disable Naming/AccessorMethodName
      def set_encoding(*)
        # DO NOTHING
      end

      def close(*)
        @gzip.close
      end
    end
  end
end
