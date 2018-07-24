# frozen_string_literal: true

module Repository
  require_relative 'repository/base_mongoid_repository'
  require_relative 'repository/base_s3_repository'
  require_relative 'repository/file_storage_repository'
  require_relative 'repository/repository_response'
end
