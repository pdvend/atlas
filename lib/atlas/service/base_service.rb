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
          hook_params = hook

          instance.instance_exec do
            hook_params[:instance].execute(*args, *hook_params[:args]) do |*internal_args, &block|
              instance_exec(*internal_args, block, &hook_params[:block])
            end
          end
        end
      end

      def self.prepended(base)
        base.class_eval do
          @base_service_hooks = []

          if defined?(NewRelic) && method_defined?(:execute)
            include ::NewRelic::Agent::MethodTracer
          end

          def self.hook(klass, *args, &block)
            block ||= ->(*) {}
            @base_service_hooks << Hook.new(klass.new, args, block)
            include klass::DSL if klass.constants.include?(:DSL)
          end
        end
      end

      def execute(context, params)
        hook_response = self.class.trace_execution_scoped(["#{self.name}/execute/hooks"]) do
          execute_hooks(context, params)
        end

        return hook_response if hook_response

        self.class.trace_execution_scoped(["#{self.name}/execute/body"]) do
          super(context, params)
        end
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
