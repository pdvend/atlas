# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module FindInBatchesEnum
          def find_in_batches_enum(sorting: [], filtering: [])
            query = apply_statements(sorting: sorting, filtering: filtering)

            Enumerator.new do |yielder|
              query
                .each
                .map(&method(:model_to_entity))
                .each(&yielder.method(:<<))
              # TODO: Catch errors
            end
          end
        end
      end
    end
  end
end
