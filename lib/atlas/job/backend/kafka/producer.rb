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
            unless message.is_a?(JobMessage)
              raise ArgumentError.new("Expected JobMessage. Received #{message.class}.")
            end

            raise ArgumentError.new("Expected valid message. Received: #{message.inspect}") unless message.valid?

            @producer.produce(message.to_json, topic: topic)
          end
        end
      end
    end
  end
end
