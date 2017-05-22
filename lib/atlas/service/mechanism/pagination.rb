module Atlas
  module Service
    module Mechanism
      module Pagination
        QueryResult = Struct.new(:total, :per_page, :results)

        def self.paginate_params(params)
          count = limit(params)
          offset = offset(params, count)
          { limit: count, offset: offset }
        end

        def self.limit(params)
          page_limit = params[:page_limit].to_i
          params_count = (params[:count] || page_limit).to_i
          [0, [params_count, page_limit].min].max
        end
        private_class_method :limit

        def self.offset(params, count)
          params_page = params[:page] || 1
          (params_page.to_i - 1) * count
        end
        private_class_method :offset
      end
    end
  end
end
