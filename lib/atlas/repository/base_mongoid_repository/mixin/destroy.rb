# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module Destroy
          def destroy(params)
            wrap do
              partial_entity = entity.new(**params)
              model.find(partial_entity.identifier).destroy
              Atlas::Repository::RepositoryResponse.new(data: nil, err_code: Enum::ErrorCodes::NONE)
            end
          end
        end
      end
    end
  end
end
