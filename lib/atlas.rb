# frozen_string_literal: true

require 'forwardable'

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
require 'httparty'
require 'delayed_job'
require 'delayed_job_mongoid'

module Atlas
  require_relative 'api'
  require_relative 'entity'
  require_relative 'enum'
  require_relative 'hook'
  require_relative 'job'
  require_relative 'repository'
  require_relative 'service'
  require_relative 'util'
  require_relative 'version'
  require_relative 'view'

  I18n.load_path ||= []
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), '../locale/*.yml')]

  PDFKit.configure do |config|
    config.wkhtmltopdf = WkhtmltopdfBinary.path
  end
end
