# frozen_string_literal: true

module Atlas
  module Job
    module Backend
      class Kafka
        class Producer
          def initialize(producer)
            @producer = producer
          end

          def produce_batch(topic, batch)
            batch.each { |message| internal_produce(topic, message) }
            @producer.deliver_messages
          end

          def produce(topic, message)
            internal_produce(topic, message)
            @producer.deliver_messages
          end

          private

          def internal_produce(topic, message)
            check_message(message)
            @producer.produce(message.to_json, topic: topic)
          end

          def check_message(message)
            return if message.is_a?(JobMessage) && message.valid?
            raise ArgumentError, "Expected valid message. Received: #{message.inspect}"
          end
        end
      end
    end
  end
end
