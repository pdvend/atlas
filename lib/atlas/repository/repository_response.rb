module Platform
  module Repository
    class RepositoryResponse < Platform::Entity::BaseEntity
      parameters :data, :success

      schema do
        required(:data)
        required(:success).filled(:bool?)
      end

      alias success? success
    end
  end
end
