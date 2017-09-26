module Atlas
  module Service
    module Mechanism
      class Filtering
        OPERATORS = %i[eq lt gt lte gte not like].freeze
        CONJUNCTIONS = %i[and or].freeze
        DEFAULT_CONJUNCTION = :and
        FILTERS_SEPARATOR = ','.freeze
        FILTER_PARTS_SEPARATOR = /(?:(#{CONJUNCTIONS.join('|')}):)?([a-zA-Z0-9_.-]+):(#{OPERATORS.join('|')}):(.*)/

        def self.filter_params(params, entity)
          return [] unless params.is_a?(String)
          filter_strings = params.split(FILTERS_SEPARATOR)
          filter_strings.map { |filter_string| generate_filter(entity, filter_string) }.compact
        end

        def self.normalize_filter(entity, filter_parts)
          _, conjunction, field, operator, value = filter_parts
          conjunction ||= DEFAULT_CONJUNCTION
          value = normalize_value(entity, field.to_sym, value)
          [conjunction.to_sym, field.to_sym, operator.to_sym, value]
        end
        private_class_method :normalize_filter

        def self.normalize_value(entity, field, value)
          return value unless entity.instance_filterable_subparameters.keys.include?(field)
          value.send(entity.instance_filterable_subparameters[field])
        end
        private_class_method :normalize_value

        def self.validate_filter_parts(entity, filter_parts)
          conjunction, field, operator = filter_parts[0, 3]
          return false unless CONJUNCTIONS.include?(conjunction)
          return false unless OPERATORS.include?(operator)
          return true if entity.instance_parameters.include?(field)
          entity.instance_filterable_subparameters.keys.include?(field)
        end
        private_class_method :validate_filter_parts

        def self.generate_filter(entity, filter_string)
          raw_statments_parts = filter_string.match(FILTER_PARTS_SEPARATOR).to_a
          filter_part = normalize_filter(entity, raw_statments_parts)
          filter_part if validate_filter_parts(entity, filter_part)
        end
        private_class_method :generate_filter
      end
    end
  end
end
