# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module FilterParser
        STATEMENT_PARSERS = {
          eq: ->(value) { value },
          like: ->(value) { Regexp.new(Regexp.escape("#{value}").sub('%', '.*'), 'i') },
          not: ->(value) { { '$ne'.to_sym => value } },
          include: ->(value) { value },
          in: ->(value) { [value] },
          nin: ->(value) { [value]}
        }.freeze

        DEFAULT_STATEMENT_PARSER = ->(operator, value) { { "$#{operator}".to_sym => value } }

        module_function

        def filter_params(model, filter_statements)
          filter_statements
            .map(&PARSE_FILTER_STATEMENT[model])
            .reduce(nil, &COMPOSE_FILTER_STATEMENTS)
        end

        COMPOSE_FILTER_STATEMENTS = lambda do |current, (conjunction, statement)|
          return statement unless current

          key = conjunction == :and ? :$and : :$or

          if statement.keys.first === key
            { key => [current, *statement[key]] }
          else
            { key => [current, statement] }
          end
        end

        PARSE_FILTER_STATEMENT = lambda do |model|
          field_type = lambda do |field|
            model
              .fields[field]
              .try(:options)
              .try(:[], :type)
          end

          parse_value = lambda do |field, value|
            return value if field_type[field] != DateTime

            begin
              DateTime.parse(value)
            rescue StandardError
              value
            end
          end

          return lambda do |statement|
            conjunction, sym_field, operator, raw_value = statement
            field = sym_field.to_s
            value = parse_value[field, raw_value]
            matcher = STATEMENT_PARSERS[operator].try(:[], value) || DEFAULT_STATEMENT_PARSER[operator, value]
            [conjunction, { field => matcher }]
          end
        end
      end
    end
  end
end
