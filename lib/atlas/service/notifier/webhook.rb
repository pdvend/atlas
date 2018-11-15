# frozen_string_literal: true

module Atlas
  module Service
    module Notifier
      class Webhook
        ERROR_FORMAT = [
          '%s *Ocorreu um erro!*',
          'Contexto: `%s`',
          'Mensagem: `%s`',
          "Stacktrace:\n```\n%s\n```"
        ].join("\n").freeze

        FORMAT_TAGS = ->(*tags) { tags.map { |tag| "[` #{tag} `]" }.join }

        def initialize(webhook_urls)
          @webhook_urls = webhook_urls
        end

        def send_message(params)
          return if @webhook_urls.blank?
          params[:text] = "[`#{ENV['SERVER_ENV']}`] #{params[:text]}"
          @webhook_urls.each { |url| HTTParty.post(url, body: params.to_json) if url.present? }
        end

        # :reek:LongParameterList
        def send_error(error, context = {}, tags = [], additional_info = '')
          message = format(
            ERROR_FORMAT,
            FORMAT_TAGS[Time.now.iso8601, *tags],
            context.try(:to_json),
            error.message.tr('`', "'"),
            error.backtrace[0, 15].join("\n").gsub('```', "'``")
          )

          message << "\nInformações adicionais: #{additional_info}" unless additional_info.blank?

          send_message(text: message)
        end
      end
    end
  end
end
