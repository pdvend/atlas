# frozen_string_literal: true

module Atlas
  module Service
    module Mechanism
      module Grouping
        GROUP_FIELDS_DIVIDER = '!'
        DIVIDER_FLAG = ','
        TRANSFORMATION_SEPARATOR = ':'
        VALID_GROUPING_OPERATIONS = %i[sum count last max min first avg].freeze

        def self.group_params(params, entity)
          group_fields_str, *raw_transformations = params.try(:split, DIVIDER_FLAG)

          return false unless group_fields_str.present?

          group_fields = group_fields_str.split(GROUP_FIELDS_DIVIDER)
          return if entity.present? && !entity.can_group_by?(group_fields)

          transformations = raw_transformations.lazy
              .map { |field| generate_grouping_statement(field) }
              .select { |statement| valid_grouping_statement?(statement, entity) }

          { group_fields: group_fields, transformations: transformations }
        end

        def self.generate_grouping_statement(field)
          field_name, operation = field.split(TRANSFORMATION_SEPARATOR)
          { field: field_name.try(:to_sym), operation: operation.try(:to_sym) }
        end
        private_class_method :generate_grouping_statement

        def self.valid_grouping_statement?(statement, entity)
          VALID_GROUPING_OPERATIONS.include?(statement[:operation]) &&
            (!entity || entity.can_transform?(statement[:field]))
        end
        private_class_method :valid_grouping_statement?
      end
    end
  end
end
