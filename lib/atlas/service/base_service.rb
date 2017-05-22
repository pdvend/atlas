module Atlas
  module Service
    module BaseService
      def self.prepended(base)
        base.class_eval do
          @base_service_hooks = []

          def self.hook(klass, *args, &block)
            @base_service_hooks << { klass: klass.new, args: args, block: block }
            include klass::DSL if klass.constants.include?(:DSL)
          end
        end
      end

      def execute(context, params)
        execute_hooks(context, params) || super(context, params)
      end

      private

      def execute_hooks(context, params)
        self.class
            .instance_variable_get(:@base_service_hooks)
            .lazy
            .map { |hook| execute_hook(hook, context, params) }
            .find { |result| !result.success? }
      end

      def execute_hook(hook, *args)
        hook[:klass].execute(*args, *hook[:args]) do |*internal_args, &block|
          instance_exec(*internal_args, block, &hook[:block])
        end
      end
    end
  end
end
