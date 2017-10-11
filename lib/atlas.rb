# frozen_string_literal: true

require 'active_support/dependencies'
require 'active_support/core_ext/object/try'
require 'active_support/time_with_zone'
require 'aws-sdk'
require 'dry-validation'
require 'dry-configurable'
require 'hanami-controller'
require 'ice_nine'
require 'i18n'
require 'json_serializer'
require 'mongoid'
require 'pdfkit'
require 'rack'
require 'wkhtmltopdf_binary'

module Atlas
  ActiveSupport::Dependencies.autoload_paths ||= []
  ActiveSupport::Dependencies.autoload_paths.push(File.dirname(__FILE__))

  I18n.load_path ||= []
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), '../locale/*.yml')]

  PDFKit.configure do |config|
    config.wkhtmltopdf = WkhtmltopdfBinary.path
  end
end
