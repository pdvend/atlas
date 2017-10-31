# frozen_string_literal: true

module Atlas
  module Job
    class DjProcessor
      include Atlas::Service::Util::ResponseHelpers
      include Concurrent::Async if defined?(Concurrent)

      JobKeeper = Class.new(StandardError)

      JobWrapper = Struct.new(:notifier, :job_class, :payload) do
        extend Forwardable

        DONT_RAISE_RESULTS = [
          Atlas::Enum::JobsResponseCodes::PROCESS_MESSAGE,
          Atlas::Enum::JobsResponseCodes::FAILED_NO_RETRY
        ].freeze

        def perform
          result = job_class.new.perform(payload)
          # When job succeeds or fails and don't need retry, our job is done
          return if DONT_RAISE_RESULTS.include?(result)
          # Else, we should force the exception to not take the job from the queue
          raise JobKeeper
        end

        def_delegator :job_class, :retries, :max_attempts
        def_delegator :job_class, :topic, :queue_name

        def reschedule_at(current_time, _attempts)
          current_time + job_class.timeout_delay
        end

        def error(_job, error)
          return if error.is_a?(JobKeeper)
          notifier.send_error(error, Atlas::Service::SystemContext, [], "`#{payload.to_json}`")
        end

        def failure(_job)
          notifier.send_message(text: "Unprocessed message for job #{job_class.name}: `#{payload.to_json}`")
        end
      end

      def initialize(notifier:, worker_options: {})
        @notifier = notifier
        @worker_options = worker_options
      end

      def enqueue(job, payload: {})
        dj_job = JobWrapper.new(@notifier, job, payload)
        Delayed::Job.enqueue(dj_job)
      end

      def process
        # This will loop indefinitely, yielding each message in turn.
        Delayed::Worker.new(@worker_options).start
        successful_response({})
      end
    end
  end
end
