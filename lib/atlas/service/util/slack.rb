require 'httparty'

module Atlas
  module Service
    module Util
      class Slack
        def initialize(webhook_url)
          @webhook_url = webhook_url
        end

        def send(msg)
          HTTParty.post(@webhook_url, body: { text: msg }.to_json)
        end
      end
    end
  end
end
