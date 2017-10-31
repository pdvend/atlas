# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module FindOne
          def find_one(statements)
            find_result = wrap { internal_find_one(statements) }
            return false unless find_result.success
            data = find_result.data
            return false if data[:total] != 1
            model_to_entity(data[:result].first)
          end

          private

          def internal_find_one(statements)
            result = apply_statements(statements)
            data = { result: result, total: result.count }
            Atlas::Repository::RepositoryResponse.new(data: data, success: true)
          end
        end
      end
    end
  end
end
