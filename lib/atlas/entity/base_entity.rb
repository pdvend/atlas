module Atlas
  module Entity
    class BaseEntity
      extend Dry::Configurable
      setting :messages_file

      def self.schema(&block)
        schema = Dry::Validation.Schema do
          configure do
            config.messages_file = BaseEntity.config.messages_file
          end

          instance_eval(&block)
        end

        define_method(:model_schema, ->() { schema })
        private :model_schema
      end

      def self.parameters(*names)
        sym_names = names.map(&:to_sym)
        undef_internal_methods
        define_internal_methods(sym_names)
        sym_names.each { |name| define_accessor_methods(name) }
      end

      def self.define_internal_methods(sym_names)
        parameters_proc = ->() { sym_names }
        define_method(:internal_parameters, parameters_proc)
        define_singleton_method(:instance_parameters, parameters_proc)
      end
      private_class_method :define_internal_methods

      def self.undef_internal_methods
        if method_defined?(:internal_parameters)
          undef_method(:internal_parameters)
        end

        return unless singleton_class.send(:method_defined?, :instance_parameters)
        singleton_class.send(:undef_method, :instance_parameters)
      end
      private_class_method :undef_internal_methods

      def self.define_accessor_methods(name)
        define_reader_method(name)
        define_writer_method(name)
      end
      private_class_method :define_accessor_methods

      def self.define_reader_method(name)
        define_method(name) do
          @parameters[name]
        end
      end
      private_class_method :define_reader_method

      def self.define_writer_method(name)
        define_method("#{name}=") do |value|
          @parameters[name] = value
          @dirty << name unless @dirty.include?(name)
          refresh_validation
          value
        end
      end
      private_class_method :define_writer_method

      attr_reader :errors

      def initialize(**parameters)
        @errors = IceNine.deep_freeze({})
        @parameters = parameters
        @dirty = []
        @valid = true
        refresh_validation
      end

      def valid?
        @valid
      end

      def to_hash(dirty = false)
        keys = internal_parameters & (dirty ? @dirty : internal_parameters)
        values = @parameters.values_at(*keys)
        keys.zip(values).to_h
      end
      alias to_h to_hash

      def to_json(*args)
        to_hash.to_json(*args)
      end

      def clean!
        @dirty = []
      end

      private

      def refresh_validation
        return unless model_schema
        result = model_schema.call(@parameters)
        @errors = IceNine.deep_freeze(result.errors)
        @valid = result.success?
      end
    end
  end
end
