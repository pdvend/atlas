# frozen_string_literal: true

module Atlas
  module Entity
    class BaseEntity
      def self.schema(&block)
        schema = Dry::Validation.Schema do
          configure { config.messages = :i18n }
          instance_eval(&block)
        end

        define_model_schema(schema)
      end

      def self.define_model_schema(schema)
        define_method(:model_schema, ->() { schema })
        private :model_schema
      end

      def self.subparameters(instance_subparameters)
        define_singleton_method(:instance_subparameters) { instance_subparameters }
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
        define_singleton_method(:instance_subparameters) { {} } unless method_defined?(:instance_subparameters)
        undef_method(:internal_parameters) if method_defined?(:internal_parameters)
        return unless singleton_class.send(:method_defined?, :instance_parameters)
        singleton_class.send(:undef_method, :instance_parameters)
      end
      private_class_method :undef_internal_methods

      def self.define_accessor_methods(name)
        define_method(name) { self[name] }
        define_method("#{name}=") { |value| self[name] = value }
      end
      private_class_method :define_accessor_methods

      attr_reader :errors, :valid, :dirty_attributes
      alias identifier hash
      alias valid? valid

      def initialize(**parameters)
        @errors = IceNine.deep_freeze({})
        @parameters = parameters
        @valid = true
        @dirty_attributes = {}
        refresh_validation
      end

      # TO OVERRIDE
      def self.can_transform?(field)
        true
      end

      # TO OVERRIDE
      def self.can_group_by?(field)
        true
      end

      def to_hash
        keys = dynamic_attributes? ? @parameters.keys : internal_parameters
        values = @parameters.values_at(*keys)
        keys.zip(values).to_h
      end
      alias to_h to_hash

      def to_json(*args)
        to_hash.to_json(*args)
      end

      def [](key)
        @parameters[key]
      end

      def []=(key, value)
        organize_dirty_attributes(key, value)

        @parameters[key] = value
        refresh_validation
      end

      def was?(key)
        return self[key] unless dirty_attributes[key]
        dirty_attributes[key][:was]
      end

      protected

      def dynamic_attributes?
        false
      end

      private

      def reorganize_dirty_attributes_key(key, value)
        if @dirty_attributes[key][:was] == value
          @dirty_attributes.delete(key)
        else
          @dirty_attributes[key][:value] = value
        end
      end

      def organize_dirty_attributes(key, value)
        if @dirty_attributes.key?(key)
          reorganize_dirty_attributes_key(key, value)
        else
          self_key = self[key]
          @dirty_attributes[key] = { was: self_key, value: value } if self_key != value
        end
      end

      def refresh_validation
        return unless model_schema
        result = model_schema.call(@parameters)
        @errors = IceNine.deep_freeze(result.errors)
        @valid = result.success?
      end
    end
  end
end
