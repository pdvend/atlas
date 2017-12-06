# frozen_string_literal: true

module Atlas
  module Job
    class Noop
      include Concurrent::Async if defined?(Concurrent)

      JobWrapper = Struct.new(:notifier, :job_class, :payload) do
        extend Forwardable

        def perform
        end

        def_delegator :job_class, :retries, :max_attempts
        def_delegator :job_class, :topic, :queue_name

        def reschedule_at(current_time, _attempts)
          current_time + job_class.timeout_delay
        end

        def error(_job, error)
        end

        def failure(_job)
        end
      end

      def enqueue(job, payload: {}, delay: 0)
      end

      def process
        loop {}
      end
    end
  end
end
