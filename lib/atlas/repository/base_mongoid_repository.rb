# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      I18N_SCOPE = %i[atlas repository base_mongoid_repository].freeze

      include Mixin::Create
      include Mixin::FindOne
      include Mixin::FindLast
      include Mixin::FindPaginated
      include Mixin::FindInBatchesEnum
      include Mixin::Transform
      include Mixin::Update
      include Mixin::Destroy

      def initialize(model:, entity:)
        @model = model
        @entity = entity
      end

      protected

      attr_reader :model, :entity

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

      def apply_statements(sorting: [], filtering: [], pagination: {}, grouping: false)
        [
          [:apply_pagination, pagination],
          [:apply_order,      sorting],
          [:apply_filter,     filtering],
          [:apply_group,      grouping]
        ].reduce(model) do |mod, (meth, param)|
          method(meth).call(mod, param)
        end
      end

      def apply_pagination(model, offset: nil, limit: nil)
        criteria = model
        criteria = criteria.offset(offset) if offset
        criteria = criteria.limit(limit) if limit
        criteria
      end

      def apply_order(model, sorting)
        sorting ? model.order(OrderParser.order_params(model, sorting)) : model
      end

      def apply_filter(model, filtering)
        filtering ? model.where(FilterParser.filter_params(model, filtering)) : model.all
      end

      def apply_group(model, grouping)
        return model unless grouping
        grouped = model.group(GroupParser.group_params(model, grouping))

        model.collection(grouped.pipeline).each.map do |row|
          { 'uuid' => row['_id'], **row }.except('_id')
        end
      end

      def model_to_entity(element)
        entity.new(**element.attributes.symbolize_keys)
      end
    end
  end
end
