module Atlas
  module Util
    module Slack
      WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']

      def notificate_slack(msg)
        HTTParty.post(WEBHOOK_URL, body: { text: msg }.to_json)
      end
    end
  end
end
