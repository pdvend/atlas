# frozen_string_literal: true

module Atlas
  module Service
    module Mechanism
      class Filtering
        OPERATORS = %i[eq lt gt lte gte not like in nin].freeze
        CONJUNCTIONS = %i[and or].freeze
        DEFAULT_CONJUNCTION = :and
        FILTERS_SEPARATOR = ','
        FILTER_PARTS_SEPARATOR = /(?:(#{CONJUNCTIONS.join('|')}):)?([a-zA-Z0-9_\.-]+):(#{OPERATORS.join('|')}):(.*)/

        def self.filter_params(params, entity)
          return [] unless params.is_a?(String)
          filter_strings = params.split(FILTERS_SEPARATOR)
          filter_strings.map { |filter_string| generate_filter(entity, filter_string) }.compact
        end

        def self.normalize_filter(entity, filter_parts)
          _, conjunction, raw_field, operator, value = filter_parts
          field = raw_field.try(:to_sym)
          conjunction ||= DEFAULT_CONJUNCTION
          value = normalize_value(entity, field, value)
          [conjunction.to_sym, field, operator.try(:to_sym), value_by_operator(operator, value)]
        end
        private_class_method :normalize_filter

        def self.value_by_operator(operator, value)
          array_operators = ['in', 'nin']
          array_operators.include?(operator) ? value.delete('[]').split('|') : value
        end

        def self.normalize_value(entity, field, value)
          value = nil if value == '!null!'
          return value unless entity
          subparameters = entity.instance_subparameters
          return value unless subparameters.keys.include?(field)
          value.send(subparameters[field])
        end
        private_class_method :normalize_value

        def self.validate_filter_parts(entity, filter_parts)
          conjunction, field, operator = filter_parts[0, 3]
          return false unless CONJUNCTIONS.include?(conjunction)
          return false unless OPERATORS.include?(operator)
          return true if !entity || entity.instance_parameters.include?(field)
          entity.instance_subparameters.keys.include?(field)
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
