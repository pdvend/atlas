module Atlas
  module Service
    module Telemetry
      module Adapter
        class KafkaAdapter
          include Atlas::Util::I18nScope

          KAFKA = 'vendor.kafka'.freeze
          TELEMETRY_KAFKA_TOPIC = ENV['TELEMETRY_KAFKA_TOPIC']

          def initialize
            @kafka = Atlas::Dependencies[KAFKA]
            @producer = @kafka.producer
          end

          def log(type, data)
            message = {
              type: type,
              data: data
            }

            @producer.produce(message.to_json, topic: TELEMETRY_KAFKA_TOPIC)
            @producer.deliver_messages

            ServiceResponse.new(data: nil, code: Enum::ErrorCodes::NONE)
          rescue
            error_message = I18n.t(:service_unavailable, scope: i18n_scope)
            ServiceResponse.new(message: error_message, data: {}, code: Enum::ErrorCodes::INTERNAL)
          end
        end
      end
    end
  end
end
