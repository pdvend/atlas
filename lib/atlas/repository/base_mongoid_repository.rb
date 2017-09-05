module Atlas
  module Repository
    class BaseMongoidRepository
      STATEMENT_PARSERS = {
        eq: ->(value) { value },
        like: ->(value) { Regexp.new(Regexp.escape(value).sub('%', '.*'), 'i') },
        not: ->(value) { { '$ne'.to_sym => value } },
        include: ->(value) { value }
      }.freeze
      private_constant :STATEMENT_PARSERS

      DEFAULT_STATEMENT_PARSER = ->(operator, value) { { "$#{operator}".to_sym => value } }
      private_constant :DEFAULT_STATEMENT_PARSER

      TRANSFORM_OPERATIONS = {
        sum: ->(collection, field) { collection.sum(field) },
        count: ->(collection, _field) { collection.count }
      }
      private_constant :TRANSFORM_OPERATIONS

      def find(statements)
        result = apply_statements(statements)
        entities = result.to_a.map(&method(:model_to_entity))
        Atlas::Repository::RepositoryResponse.new(data: entities, success: true)
      end

      def find_paginated(statements)
        result = apply_statements(statements)
        entities = result.to_a.map(&method(:model_to_entity))
        data = { response: entities, total: result.count }
        response = Atlas::Repository::RepositoryResponse.new(data: data, success: true)
      end

      # DEPRECATED
      # Prefer find_in_batches_enum
      def find_in_batches(batch_size, statements)
        query = apply_statements(statements)
        offset = 0
        limit = batch_size

        loop do
          models = query.offset(offset).limit(batch_size).to_a
          break if models.empty?
          yield models.map(&method(:model_to_entity))
          offset += batch_size
        end
      end

      def find_in_batches_enum(statements)
        query = apply_statements(**statements, pagination: { offset: 0, limit: 1 })

        Enumerator.new do |yielder|
          query
            .each
            .map(&method(:model_to_entity))
            .each(&yielder.method(:<<))
          # TODO: Catch errors
        end
      end

      def transform(statements)
        collection = model.where(filter_params(statements[:filtering] || []))
        operation = statements[:transform][:operation].to_sym
        field = statements[:transform][:field].try(:to_sym)
        result = TRANSFORM_OPERATIONS[operation][collection, field]
        Atlas::Repository::RepositoryResponse.new(data: result, success: true)
      end

      def create(entity)
        return error('Invalid entity') unless entity.is_a?(Entity::BaseEntity)
        params = entity.to_h
        params[:_id] = entity.identifier
        model.create(**params)
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Mongo::Error::OperationFailure => err
        error(err)
      rescue Mongoid::Errors::MongoidError => err
        error(err)
      end

      def update(params)
        partial_entity = entity.new(**params)
        identifier = partial_entity.identifier
        instance = model.find(identifier)
        instance.update_attributes(**params)
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Mongo::Error::OperationFailure => err
        error(err)
      rescue Mongoid::Errors::MongoidError => err
        error(err)
      end

      def destroy(params)
        partial_entity = entity.new(**params)
        identifier = partial_entity.identifier
        instance = model.find(identifier)
        instance.destroy
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
          order: order_params(statements[:sorting] || []),
          where: filter_params(statements[:filtering] || [])
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
