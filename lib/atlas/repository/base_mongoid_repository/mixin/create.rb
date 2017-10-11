# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module Create
          GET_PARAMS = ->(entity) { { **entity.to_h, _id: entity.identifier } }

          def create(entity)
            wrap do
              return error('Invalid entity') unless entity.is_a?(Entity::BaseEntity)
              model.create(Create::GET_PARAMS[entity])
              Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
            end
          end
        end
      end
    end
  end
end
