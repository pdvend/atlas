# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module GroupParser
        STATEMENT_PARSERS = {
          sum: ->(field) { { '$sum' => "$#{field}" } },
          count: ->(_field) { { '$sum' => 1 } },
          last: ->(field) { { '$last' => "$#{field}" } },
          max: ->(field) { { '$max' => "$#{field}" } },
          min: ->(field) { { '$min' => "$#{field}" } },
          first: ->(field) { { '$first' => "$#{field}" } },
          avg: ->(field) { { '$avg' => "$#{field}" } }
        }.freeze

        module_function

        def group_params(_model, group_fields:, transformations:)
          group_fields.map.with_index do |group_field, index|
            next_groups = group_fields[(index + 1)..-1].map { |field| [field, { "$last" => "$#{field}"}] }.to_h
            initial_group = { _id: "$#{group_field}" }.merge(next_groups)
            transformations.reduce(initial_group, &method(:compose_group_options))
          end
        end

        def compose_group_options(current, field:, operation:)
          parser = STATEMENT_PARSERS[operation]
          output_field = field.to_s.gsub('.', '_').to_sym
          parser ? { **current, output_field => parser[field] } : current
        end
      end
    end
  end
end
