# frozen_string_literal: true

module Atlas
  module Service
    module Telemetry
      module Adapter
        class KafkaAdapter
          include Atlas::Util::I18nScope

          def initialize(kafka, topic)
            @producer = kafka.producer
            @topic = topic
          end

          def log(type, data)
            deliver(type: type, data: data)
            ServiceResponse.new(data: nil, code: Enum::ErrorCodes::NONE)
          rescue StandardError
            error_message = I18n.t(:service_unavailable, scope: i18n_scope)
            ServiceResponse.new(message: error_message, data: {}, code: Enum::ErrorCodes::INTERNAL)
          end

          def deliver(message)
            @producer.produce(message.to_json, topic: @topic)
            @producer.deliver_messages
          end
        end
      end
    end
  end
end
