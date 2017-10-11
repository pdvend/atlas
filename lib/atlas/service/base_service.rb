# frozen_string_literal: true

module Atlas
  module Service
    module BaseService
      class Hook
        def initialize(instance, args, block)
          @instance = instance
          @args = args
          @block = block
        end

        def hook
          { block: @block, instance: @instance, args: @args }
        end

        def execute(instance, *args)
          _hook = hook

          instance.instance_exec do
            _hook[:instance].execute(*args, *_hook[:args]) do |*internal_args, &block|
              instance_exec(*internal_args, block, &_hook[:block])
            end
          end
        end
      end

      def self.prepended(base)
        base.class_eval do
          @base_service_hooks = []

          def self.hook(klass, *args, &block)
            block ||= ->(*) {}
            @base_service_hooks << Hook.new(klass.new, args, block)
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
            .map { |hook| hook.execute(self, context, params) }
            .find { |result| !result.success? }
      end
    end
  end
end
