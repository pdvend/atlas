# frozen_string_literal: true

module Atlas
  module Job
    class Noop
      include Concurrent::Async if defined?(Concurrent)

      def enqueue(_job, payload: {}, delay: 0, priority: 5)
      end

      def process
        loop {}
      end
    end
  end
end
