# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module FindPaginated
          def find_paginated(statements)
            result = apply_statements(statements)

            entities = Enumerator.new do |yielder|
              result[:query]
                .each
                .map(&method(:model_to_entity))
                .each(&yielder.method(:<<))
            end

            data = { response: entities, total: result[:count] }
            Atlas::Repository::RepositoryResponse.new(data: data, success: true)
          end
        end
      end
    end
  end
end
