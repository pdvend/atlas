# frozen_string_literal: true

module Atlas
  module Job
    class JobMessage < Atlas::Entity::BaseEntity
      parameters :topic, :payload, :retries, :timestamp, :vendor_message

      schema do
        required(:topic).filled(:str?)
        required(:payload) { hash? }
        required(:retries).filled(:int?, gteq?: 0)
        required(:timestamp).filled(:int?, gteq?: 0)
      end

      def to_hash
        super.except(:vendor_message)
      end
    end
  end
end
