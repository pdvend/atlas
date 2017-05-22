module Atlas
  module Service
    class ServiceResponse < Atlas::Entity::BaseEntity
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
