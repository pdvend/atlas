# frozen_string_literal: true

module Atlas
  module Repository
    class RepositoryResponse < Atlas::Entity::BaseEntity
      parameters :data, :err_code

      schema do
        required(:data)
        required(:err_code).filled(:int?)
      end

      def success?
        err_code == Enum::ErrorCodes::NONE
      end
    end
  end
end
