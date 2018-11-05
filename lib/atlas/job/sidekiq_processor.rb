# frozen_string_literal: true

module Atlas
  module Job
    class SidekiqProcessor
      include Atlas::Service::Util::ResponseHelpers
      include ::Sidekiq::Worker

      JobKeeper = Class.new(StandardError)

      def perform(params)
        job = params['job']
        job_instance = job.constantize.new
        payload = params['payload']
        results = [
          Atlas::Enum::JobsResponseCodes::PROCESS_MESSAGE,
          Atlas::Enum::JobsResponseCodes::FAILED_NO_RETRY
        ]

        result = job_instance.perform(payload)
        return if results.include?(result)
        notifier = Atlas::Service::Notifier::Slack.new(ENV['SLACK_WEBHOOK_URL'])
        message = "Error in sidekiq processor: `#{job_instance.class.name}: #{payload.to_json}`"
        notifier.send_message(text: message)
      end
    end
  end
end
