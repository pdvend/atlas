# frozen_string_literal: true

module Atlas
  module Repository
    class RepositoryResponse < Atlas::Entity::BaseEntity
      parameters :data, :success

      schema do
        required(:data)
        required(:success).filled(:bool?)
      end

      alias success? success
    end
  end
end
