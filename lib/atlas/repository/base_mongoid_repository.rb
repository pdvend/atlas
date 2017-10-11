# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      I18N_SCOPE = %i[atlas repository base_mongoid_repository].freeze

      include Mixin::Create
      include Mixin::Find
      include Mixin::FindPaginated
      include Mixin::FindInBatches
      include Mixin::FindInBatchesEnum
      include Mixin::Transform
      include Mixin::Update
      include Mixin::Destroy

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

      def wrap
        yield
      rescue Mongo::Error::OperationFailure => op_failure_err
        error(op_failure_err)
      rescue Mongoid::Errors::MongoidError => internal_err
        error(internal_err)
      end

      def error(message)
        Atlas::Repository::RepositoryResponse.new(data: { base: message }, success: false)
      end

      def apply_statements(sorting: [], filtering: [], pagination: {})
        [
          [:apply_pagination, pagination],
          [:apply_order,      sorting   ],
          [:apply_filter,     filtering ]
        ].reduce(model) do |mod, (meth, param)|
          method(meth).call(m, param)
        end
      end

      def apply_pagination(model, offset: nil, limit: nil)
        model
          .tap { |mod| m.offset(offset) if offset }
          .tap { |mod| m.limit(limit) if limit }
      end

      def apply_order(model, sorting)
        model.tap { |mod| m.order(OrderParser.order_params(m, sorting)) if sorting }
      end

      def apply_filter(model, filtering)
        model.tap { |mod| m.where(FilterParser.filter_params(m, filtering)) if filtering }
      end

      def model_to_entity(element)
        entity.new(**element.attributes.symbolize_keys)
      end
    end
  end
end
