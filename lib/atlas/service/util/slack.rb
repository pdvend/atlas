require 'httparty'

module Atlas
  module Service
    module Util
      class Slack
        def initialize(webhook_url)
          @webhook_url = webhook_url
        end

        def send(body)
          HTTParty.post(@webhook_url, body: body.to_json)
        end
      end
    end
  end
end
