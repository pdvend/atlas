# frozen_string_literal: true

module Atlas
  module Service
    module Mechanism
      class ServiceResponseFormatter
        def format(repository, repository_method, format_params)
          filter_params = filter_params(format_params)
          results = repository.send(repository_method, filter_params)
          return results unless results.success
          return parse_success_result_transform(results, filter_params) if repository_method == :transform
          parse_success_result_paginated(results, filter_params)
        end

        private

        def parse_success_result_paginated(results, filter_params)
          result_data = results.data
          query_result = Pagination::QueryResult.new(
            result_data[:total],
            filter_params[:pagination][:limit],
            result_data[:response]
          )
          data = IceNine.deep_freeze(query_result)
          Atlas::Repository::RepositoryResponse.new(data: data, success: true)
        end

        def parse_success_result_transform(results, filter_params)
          transform = filter_params[:transform]

          result = Transformation::TransformResult.new(
            transform[:operation],
            transform[:field],
            results.data
          )
          Atlas::Repository::RepositoryResponse.new(data: result, success: true)
        end

        def pagination_params(params)
          query_params = params[:query_params]

          {
            page_limit: params[:page_limit],
            count: query_params[:count],
            page: query_params[:page]
          }
        end

        def add_transform_params(filter_params, format_params)
          query_params = format_params[:query_params]
          transform_result = Transformation.transformation_params(query_params[:transform], format_params[:entity])
          filter_params.tap do |params|
            params[:transform] = transform_result.data if transform_result.success?
          end
        end

        def add_pagination_params(filter_params, pagination_params)
          filter_params.tap do |params|
            params[:pagination] = Pagination.paginate_params(pagination_params)
          end
        end

        def filter_params(format_params)
          entity = format_params[:entity]
          query_params = format_params[:query_params]
          constraints = format_params[:constraints] || []

          filter_params = {
            sorting: Sorting.sorting_params(query_params[:order], entity),
            filtering: Filtering.filter_params(query_params[:filter], entity) + constraints,
            grouping: Grouping.group_params(query_params[:group], entity)
          }

          return add_transform_params(filter_params, format_params) if query_params[:transform]
          add_pagination_params(filter_params, pagination_params(format_params))
        end
      end
    end
  end
end
