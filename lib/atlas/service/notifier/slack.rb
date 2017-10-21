# frozen_string_literal: true

module Atlas
  module Service
    module Notifier
      class Slack
        ERROR_FORMAT = [
          '%s *Ocorreu um erro!*',
          'Contexto: `%s`',
          'Mensagem: `%s`',
          "Stacktrace:\n```\n%s\n```"
        ].join("\n").freeze

        FORMAT_TAGS = ->(*tags) { tags.map { |tag| "[` #{tag} `]" }.join }

        def initialize(webhook_url)
          @webhook_url = webhook_url
        end

        def send_message(body)
          return if @webhook_url.blank?
          HTTParty.post(@webhook_url, body: body.to_json)
        end

        def send_error(error, context = {}, tags = [], additional_info = '')
          message = format(
            ERROR_FORMAT,
            FORMAT_TAGS[Time.now.iso8601, *tags],
            context.try(:to_json),
            error.message.tr('`', "'"),
            error.backtrace[0, 10].join("\n").gsub('```', "'``")
          )

          message << "\nInformações adicionais: #{additional_info}" unless additional_info.blank?

          send_message(text: message)
        end
      end
    end
  end
end
