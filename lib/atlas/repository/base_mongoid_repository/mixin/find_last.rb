# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module FindLast
          def find_last(statements)
            return false unless statements[:sorting]
            find_result = wrap { internal_find_last(statements) }
            return false unless find_result.success
            data = find_result.data
            return false unless data[:total] > 0
            model_to_entity(data[:result].last)
          end

          private

          def internal_find_last(statements)
            result = apply_statements(statements)
            data = { result: result, total: result.count }
            Atlas::Repository::RepositoryResponse.new(data: data, success: true)
          end
        end
      end
    end
  end
end
