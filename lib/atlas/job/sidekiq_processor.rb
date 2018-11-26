# frozen_string_literal: true

module Atlas
  module Job
    class SidekiqProcessor
      include Atlas::Service::Util::ResponseHelpers
      include ::Sidekiq::Worker

      def initialize
        @notifier = Atlas::Service::Notifier::Webhook.new([ENV['SLACK_WEBHOOK_URL'], ENV['LOGENTRIES_WEBHOOK_URL']])
      end

      def perform(params)
        job = params['job']
        job_instance = job.constantize.new
        payload = params['payload'].try(:deep_symbolize_keys)
        results = [
          Atlas::Enum::JobsResponseCodes::PROCESS_MESSAGE,
          Atlas::Enum::JobsResponseCodes::FAILED_NO_RETRY
        ]

        result = job_instance.perform(payload)
        return if results.include?(result)

        message = "Error in sidekiq processor: `#{job_instance.class.name}: #{payload.to_json}`"
        @notifier.send_message(text: message)
      rescue StandardError => error
        @notifier.send_error(error, Atlas::Service::SystemContext, [], "#{message} \n #{error}")
      end
    end
  end
end
