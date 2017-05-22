require 'active_support/dependencies'
require 'active_support/core_ext/object/try'
require 'active_support/time_with_zone'
require 'dry-validation'
require 'ice_nine'
require 'rack'

module Atlas
  ActiveSupport::Dependencies.autoload_paths ||= []
  ActiveSupport::Dependencies.autoload_paths.push(File.dirname(__FILE__))
end
