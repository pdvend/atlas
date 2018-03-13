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
          avg: ->(field) { { '$avg' => "$#{field}" } },
          avg_count: ->(field) { { '$avg' => { '$sum' => 1 } }
        }.freeze

        module_function

        def group_params(_model, group_field:, transformations:)
          transformations.reduce({ _id: "$#{group_field}" }, &method(:compose_group_options))
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
