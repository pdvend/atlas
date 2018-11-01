# frozen_string_literal: true

module Atlas
  module Job
    class SidekiqProcessor
      include Atlas::Service::Util::ResponseHelpers
      include ::Sidekiq::Worker

      JobKeeper = Class.new(StandardError)

      def perform(job, payload: {}, delay: 0, priority: 5)
        job_instance = job.constantize.new
        results = [
          Atlas::Enum::JobsResponseCodes::PROCESS_MESSAGE,
          Atlas::Enum::JobsResponseCodes::FAILED_NO_RETRY
        ]

        result = job_instance.perform(payload)
        # When job succeeds or fails and don't need retry, our job is done
        return if results.include?(result)
        # Else, we should force the exception to not take the job from the queue
        notifier = Atlas::Service::Notifier::Slack.new(ENV['SLACK_WEBHOOK_URL'])
        notifier.send_error(error, Atlas::Service::SystemContext, [], "`#{job_instance.class.name}: #{payload.to_json}`")
        raise JobKeeper
      end
    end
  end
end
