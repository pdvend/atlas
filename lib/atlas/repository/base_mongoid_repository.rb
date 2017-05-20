module Atlas
  module Repository
    class BaseMongoidRepository
      STATEMENT_PARSERS = {
        eq: ->(value) { value },
        like: ->(value) { Regexp.new(Regexp.escape(value).sub('%', '.*'), 'i') }
      }.freeze
      private_constant :STATEMENT_PARSERS

      DEFAULT_STATEMENT_PARSER = ->(operator, value) { { "$#{operator}".to_sym => value } }
      private_constant :DEFAULT_STATEMENT_PARSER

      def find(statements)
        result = apply_statements(statements)
        entities = result.to_a.map(&method(:model_to_entity))
        Atlas::Repository::RepositoryResponse.new(data: entities, success: true)
      end

      def create(params)
        model.create(**params)
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Mongoid::Errors::MongoidError => error
        Atlas::Repository::RepositoryResponse.new(data: { base: error }, success: false)
      end

      def upsert(params)
        instance = model.new(**params)
        instance.upsert
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Mongoid::Errors::MongoidError => error
        Atlas::Repository::RepositoryResponse.new(data: { base: error }, success: false)
      end

      protected

      # :nocov:
      def model
        raise 'Implement the method #model in order to use BaseMongoidRepository.'
      end

      def entity
        raise 'Implement the method #model in order to use BaseMongoidRepository.'
      end
      # :nocov:

      private

      def apply_statements(statements)
        params = get_params(statements)

        model.offset(params[:offset])
             .limit(params[:limit])
             .order(params[:order])
             .where(params[:where])
      end

      def get_params(statements)
        pagination = statements[:pagination]

        {
          offset: pagination[:offset],
          limit: pagination[:limit],
          order: order_params(statements[:sorting]),
          where: filter_params(statements[:filtering])
        }
      end

      def model_to_entity(element)
        entity.new(**element.attributes.symbolize_keys)
      end

      def parse_statement(statement)
        _, field, operator, value = statement
        matcher = STATEMENT_PARSERS[operator].try(:[], value) || DEFAULT_STATEMENT_PARSER[operator, value]
        { field => matcher }
      end

      def order_params(order_statements)
        order_statements.each_with_object({}) do |current, order_option|
          order_option[current[:field]] = current[:direction]
        end
      end

      def filter_params(filter_statements)
        filter_statements.reduce(nil, &method(:compose_statements))
      end

      def compose_statements(current, statement)
        parsed_statement = parse_statement(statement)
        return parsed_statement unless current
        key = statement.first == :and ? :$and : :$or
        { key => [current, parsed_statement] }
      end
    end
  end
end
