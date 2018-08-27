# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module FindEnum
          def find_enum(statements)
            apply_statements(statements)[:query].each
          end
        end
      end
    end
  end
end
