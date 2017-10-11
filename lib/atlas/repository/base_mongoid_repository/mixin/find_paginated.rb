# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module FindPaginated
          def find_paginated(statements)
            result = apply_statements(statements)
            entities = result.to_a.map(&method(:model_to_entity))
            data = { response: entities, total: result.count }
            Atlas::Repository::RepositoryResponse.new(data: data, success: true)
          end
        end
      end
    end
  end
end
