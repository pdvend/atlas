# frozen_string_literal: true

require 'httparty'

module Atlas
  module Service
    module Util
      class Slack
        ERROR_FORMAT = [
          '%s *Ocorreu um erro!*',
          'Contexto: `%s`',
          'Mensagem: `%s`',
          "Stacktrace:\n```\n%s\n```"
        ].join("\n").freeze

        def initialize(webhook_url)
          @webhook_url = webhook_url
        end

        # DEPRECATED: Use `send_message` instead
        def send(body)
          send_message(body)
        end

        def send_message(body)
          return if @webhook_url.blank?
          HTTParty.post(@webhook_url, body: body.to_json)
        end

        def send_error(error, context = {}, tags = [])
          message = format(
            ERROR_FORMAT,
            FORMAT_TAGS[Time.now.iso8601, *tags],
            context.try(:to_json),
            error.message.tr('`', "'"),
            error.backtrace[0, 10].join("\n").gsub('```', "'``")
          )

          send_message(text: message)
        end

        private

        FORMAT_TAGS = ->(*tags) { tags.map { |tag| "[` #{tag} `]" }.join }
      end
    end
  end
end
