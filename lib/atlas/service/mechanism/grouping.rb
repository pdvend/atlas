# frozen_string_literal: true

module Atlas
  module Service
    module Mechanism
      module Grouping
        DIVIDER_FLAG = ','
        TRANSFORMATION_SEPARATOR = ':'
        VALID_GROUPING_OPERATIONS = %i[sum count].freeze

        def self.group_params(params, entity)
          group_field, *raw_transformations = params.try(:split, DIVIDER_FLAG)
          transformations = raw_transformations.lazy
              .map { |field| generate_grouping_statement(field) }
              .select { |statement| valid_grouping_statement?(statement, entity) }

          { group_field: group_field, transformations: transformations }
        end

        def self.generate_grouping_statement(field)
          field_name, operation = field.split(TRANSFORMATION_SEPARATOR)
          { field: field_name.try(:to_sym), operation: operation.try(:to_sym) }
        end
        private_class_method :generate_grouping_statement

        def self.valid_grouping_statement?(statement, entity)
          VALID_GROUPING_OPERATIONS.include?(statement[:operation]) &&
            (!entity.is_a?(Hash) || entity.can_transform?(statement[:field]))
        end
        private_class_method :valid_grouping_statement?
      end
    end
  end
end
