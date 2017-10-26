# frozen_string_literal: true

require 'httparty'

# DEPRECATED: Use Atlas::Service::Notifier::Slack
module Atlas
  module Service
    module Util
      class Slack
        def initialize(webhook_url)
          @slack = Atlas::Service::Notifier::Slack.new(webhook_url)
        end

        # DEPRECATED: Use `send_message` instead
        def send(body)
          @slack.send_message(body)
        end

        def send_message(_body)
          @slack.send_message
        end

        def send_error(*args)
          @slack.send_error(*args)
        end
      end
    end
  end
end
