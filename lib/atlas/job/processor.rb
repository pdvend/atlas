# frozen_string_literal: true

module Atlas
  module Job
    # :reek:DataClump
    class Processor
      include Atlas::Service::Util::ResponseHelpers
      include Concurrent::Async if defined?(Concurrent)
      include Enum::JobsResponseCodes

      def initialize(backend:, notifier:, jobs: [])
        @backend = backend
        @notifier = notifier
        @jobs = jobs
      end

      def enqueue(job, payload: {})
        @backend.produce(job.topic, payload: payload, timestamp: 0, retries: 0)
      end

      def process
        # Register jobs
        @jobs_instance_mapping = @jobs.reduce({}, &method(:register_job_class))
        # This will loop indefinitely, yielding each message in turn.
        @backend.consume(&method(:consume_message))
        successful_response({})
      end

      private

      def register_job_class(job_instance_mapping, job_class)
        topic = job_class.topic
        @backend.listen(topic)
        { **job_instance_mapping, topic => job_class.new }
      end

      def consume_message(message)
        topic = message.topic
        job = @jobs_instance_mapping[topic]
        return @notifier.send_message(text: "Invalid topic (:#{topic})") unless job
        job_perform(job, message)
      end

      def job_perform(job, message)
        return if (Time.now.to_i - message.timestamp) <= job.class.timeout_delay
        verify_processing(job, message)
      rescue StandardError => error
        resend_job(job, message)
        @notifier.send_error(error, Atlas::Service::SystemContext, [], "`#{message.to_json}`")
      end

      def verify_processing(job, message)
        job_response = job.perform(message.payload)
        @backend.mark_message_as_processed(message)
        return unless job_response != PROCESS_MESSAGE
        resend_job(job, message) unless job_response == FAILED_NO_RETRY
        unprocessed_message(message) unless job_response == REPROCESS_MESSAGE
      end

      def resend_job(job, message)
        job_class = job.class
        number_of_retries = message.retries
        return if number_of_retries >= job_class.retries

        @backend.produce(
          job_class.topic,
          payload: message.payload,
          timestamp: Time.now.to_i,
          retries: number_of_retries.next
        )
      end

      def unprocessed_message(message)
        @notifier.send_message(text: "Unprocessed message: `#{message.to_json}`")
      end
    end
  end
end
