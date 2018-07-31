# frozen_string_literal: true

module Atlas
  module Util
    class YieldStream
      def initialize(yielder)
        @yielder = yielder
      end

      def write(data)
        return if data.empty?
        puts "YIELD STREAM: #{data}"
        @yielder << data
      end

      # rubocop:disable Naming/AccessorMethodName
      def set_encoding(*)
        # DO NOTHING
      end

      def close(*)
        # DO NOTHING
      end
    end
  end
end
