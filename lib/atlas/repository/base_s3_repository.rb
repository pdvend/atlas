# frozen_string_literal: true

module Atlas
  module Repository
    class BaseS3Repository
      EMPTY_STRING = ''
      private_constant :EMPTY_STRING

      DEFAULT_ERR_CODE = Enum::ErrorCodes::REPOSITORY_INTERNAL

      def initialize(notifier:)
        @notifier = notifier
      end

      def put(uuid, content)
        return failure unless valid_object_identifier?(uuid) && content.is_a?(String)

        wrap do
          upload(content, uuid)
          Atlas::Repository::RepositoryResponse.new(data: nil, err_code: Enum::ErrorCodes::NONE)
        end
      end

      def public_url(uuid, expires_in)
        object(uuid).presigned_url(:get, expires_in: expires_in)
      end

      def content(uuid)
        return failure unless valid_object_identifier?(uuid)
        wrap { file_content(uuid) }
      end

      def handle(uuid)
        return failure unless valid_object_identifier?(uuid)
        wrap { file_handle(uuid) }
      end

      protected

      # :nocov:
      def bucket_name
        raise 'Implement the method #bucket_name in order to use BaseMongoidRepository.'
      end
      # :nocov:

      def base_folder
        EMPTY_STRING
      end

      private

      attr_accessor :notifier

      def wrap
        yield
      rescue Aws::S3::Errors::NoSuchKey => message
        failure(message: message, code: Enum::ErrorCodes::DOCUMENT_NOT_FOUND)
      rescue Aws::S3::Errors::ServiceError => message
        failure(message: message, code: DEFAULT_ERR_CODE)
      end

      def valid_object_identifier?(uuid)
        uuid.is_a?(String) && uuid.present?
      end

      def file_content(uuid)
        path = Tempfile.new("/#{SecureRandom.uuid}-", nil)
        object(uuid).get(response_target: path)
        data = File.binread(path)
        File.unlink(path)
        Atlas::Repository::RepositoryResponse.new(data: data, err_code: Enum::ErrorCodes::NONE)
      end

      def file_handle(uuid)
        path = Tempfile.new("/#{SecureRandom.uuid}-", nil)
        object(uuid).get(response_target: path)
        data = File.open(path, File::RDONLY | File::BINARY)
        Atlas::Repository::RepositoryResponse.new(data: data, err_code: Enum::ErrorCodes::NONE)
      end

      def upload(content, dest)
        src = make_tmp(content)
        object(dest).upload_file(src)
        File.unlink(src) if File.exist?(src)
      end

      def object(remote_path)
        Aws::S3::Resource.new
                         .bucket(bucket_name)
                         .object("#{base_folder}#{remote_path}")
      end

      def make_tmp(content)
        path = "tmp/#{SecureRandom.uuid}"
        File.binwrite(path, content)
        path
      end

      def failure(message: nil, code: DEFAULT_ERR_CODE)
        notifier.send_error(message) if code == DEFAULT_ERR_CODE && message.present?
        Atlas::Repository::RepositoryResponse.new(data: nil, err_code: code)
      end
    end
  end
end
