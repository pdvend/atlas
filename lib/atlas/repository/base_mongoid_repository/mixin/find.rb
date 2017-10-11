# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module Find
          # DEPRECATED: Use find_paginated instead
          def find(statements)
            result = apply_statements(statements)
            entities = result.to_a.map(&method(:model_to_entity))
            Atlas::Repository::RepositoryResponse.new(data: entities, success: true)
          end
        end
      end
    end
  end
end
