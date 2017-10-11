# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module Update
          def update(params)
            wrap do
              partial_entity = entity.new(**params)
              model.find(partial_entity.identifier).update_attributes(**params)
              Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
            end
          end
        end
      end
    end
  end
end
