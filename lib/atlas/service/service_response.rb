module Platform
  module Service
    class ServiceResponse < Platform::Entity::BaseEntity
      parameters :data, :code

      schema do
        required(:data)
        required(:code).filled(:int?)
      end

      def success?
        code.eql?(Enum::ErrorCodes::NONE)
      end
    end
  end
end
