module Atlas
  module Service
    module Mechanism
      class ServiceResponseFormatter
        def format(format_params)
          pagination_params = pagination_params(format_params)
          filter_params = filter_params(format_params, pagination_params)
          results = yield(filter_params)
          results.success ? parse_success_result(results, filter_params) : results
        end

        private

        def parse_success_result(results, filter_params)
          result_data = results.data
          query_result = Pagination::QueryResult.new(result_data.count, filter_params[:pagination][:limit], result_data)
          data = IceNine.deep_freeze(query_result)
          Atlas::Repository::RepositoryResponse.new(data: data, success: true)
        end

        def pagination_params(params)
          query_params = params[:query_params]

          {
            page_limit: params[:page_limit],
            count: query_params[:count],
            page: query_params[:page]
          }
        end

        def filter_params(format_params, pagination_params)
          entity = format_params[:entity]
          query_params = format_params[:query_params]
          constraints = format_params[:constraints] || []

          {
            pagination: Pagination.paginate_params(pagination_params),
            sorting: Sorting.sorting_params(query_params[:order], entity),
            filtering: Filtering.filter_params(query_params[:filter], entity) + constraints
          }
        end
      end
    end
  end
end
