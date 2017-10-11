# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        # :reek:TooManyStatements
        module FindInBatches
          # DEPRECATED: Use find_in_batches_enum instead
          def find_in_batches(batch_size, statements)
            query = apply_statements(statements)
            offset = 0

            loop do
              models = query.offset(offset).limit(batch_size).to_a
              break if models.empty?
              yield models.map(&method(:model_to_entity))
              offset += batch_size
            end
          end
        end
      end
    end
  end
end
