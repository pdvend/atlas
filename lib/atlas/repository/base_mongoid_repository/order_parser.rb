# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module OrderParser
        module_function

        def order_params(_model, order_statements)
          order_statements.reduce({}, &method(:compose_order_options))
        end

        def compose_order_options(current, order_option)
          current.merge(order_option[:field] => order_option[:direction])
        end
      end
    end
  end
end
