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

      def create(entity)
        return error('Invalid entity') unless entity.is_a?(Entity::BaseEntity)
        params = entity.to_h
        params[:_id] = get_identifier(entity)
        model.create(**params)
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Mongo::Error::OperationFailure => err
        error(err)
      rescue Mongoid::Errors::MongoidError => err
        error(err)
      end

      def upsert(entity)
        return error('Invalid entity') unless entity.is_a?(Entity::BaseEntity)
        identifier = get_identifier(entity)
        return create(entity) unless model.where(_id: identifier).exists?
        model.find(identifier).update_attributes(entity.to_h(true))
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Mongo::Error::OperationFailure => err
        error(err)
      rescue Mongoid::Errors::MongoidError => err
        error(err)
      end

      def update(params)
        partial_entity = entity.new(**params)
        identifier = get_identifier(partial_entity)
        instance = model.find(identifier)
        instance.update_attributes(**params)
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Mongo::Error::OperationFailure => err
        error(err)
      rescue Mongoid::Errors::MongoidError => err
        error(err)
      end

      protected

      # :nocov:
      def model
        raise 'Implement the method #model in order to use BaseMongoidRepository.'
      end

      def entity
        raise 'Implement the method #entity in order to use BaseMongoidRepository.'
      end

      def get_identifier(params)
        raise 'Implement the method #get_identifier in order to use BaseMongoidRepository.'
      end
      # :nocov:

      private

      def error(message)
        Atlas::Repository::RepositoryResponse.new(data: { base: message }, success: false)
      end

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
        _, field, operator, raw_value = statement
        value = parse_value(field, raw_value)
        matcher = STATEMENT_PARSERS[operator].try(:[], value) || DEFAULT_STATEMENT_PARSER[operator, value]
        { field => matcher }
      end

      def parse_value(field, value)
        return value if field_type(field) != DateTime

        begin
          DateTime.parse(value)
        rescue
          value
        end
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

      def field_type(field)
        model
          .fields[field.to_s]
          .try(:options)
          .try(:[], :type)
      end
    end
  end
end
