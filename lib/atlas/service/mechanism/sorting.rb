module Atlas
  module Service
    module Mechanism
      module Sorting
        DIVIDER_FLAG = ','.freeze
        DESC_FLAG = '-'.freeze

        def self.sorting_params(params, entity)
          params
            .try(:split, DIVIDER_FLAG)
            .try(:map) { |field| generate_sorting_statement(field, entity) }
            .try(:compact) || []
        end

        def self.valid_sorting_field?(field_name, entity)
          entity.instance_parameters.include?(field_name) ||
          entity.instance_subparameters.keys.include?(field_name)
        end
        private_class_method :valid_sorting_field?

        def self.generate_sorting_statement(field, entity)
          field_name = field.sub(DESC_FLAG, '')
          return unless valid_sorting_field?(field_name.to_sym, entity)
          direction = field[0] == DESC_FLAG ? :desc : :asc
          { field: field_name, direction: direction }
        end
        private_class_method :generate_sorting_statement
      end
    end
  end
end
