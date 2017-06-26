module Atlas
  module Util
    module I18nScope
      UNDERSCORE_SEPARATOR = '/'.freeze
      SCOPE_SEPARATOR = '.'.freeze

      def i18n_scope
        return @_i18n_scope if defined?(@_i18n_scope)
        classname = (is_a?(Class) ? name : self.class.name) || ''
        @_i18n_scope ||= classname.underscore.gsub(UNDERSCORE_SEPARATOR, SCOPE_SEPARATOR)
      end
    end
  end
end
