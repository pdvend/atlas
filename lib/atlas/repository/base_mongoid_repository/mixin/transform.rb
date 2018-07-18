# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module Transform
          TRANSFORM_OPERATIONS = {
            sum: ->(collection, field) { collection.sum(field) },
            avg: ->(collection, field) { collection.avg(field) },
            count: ->(collection, _field) { collection.count }
          }.freeze

          def transform(transform:, sorting: [], filtering: [], **)
            return error(I18n.t(:transform_required, scope: I18N_SCOPE)) unless transform.is_a?(Hash)
            target_collection = apply_filter(apply_order(model, sorting), filtering)
            internal_transform(target_collection, **transform)
          end

          private

          def internal_transform(collection, operation:, field: nil)
            result = Transform::TRANSFORM_OPERATIONS[operation][collection, field.try(:to_sym)]
            debugger
            Atlas::Repository::RepositoryResponse.new(data: result, err_code: Enum::ErrorCodes::NONE)
          end
        end
      end
    end
  end
end
