# frozen_string_literal: true

module Atlas
  module Repository
    class BaseS3Repository
      EMPTY_STRING = ''
      private_constant :EMPTY_STRING

      def initialize(notifier:)
        @notifier = notifier
      end

      def put(uuid, content)
        return failure unless valid_object_identifier?(uuid) && content.is_a?(String)

        wrap do
          upload(content, uuid)
          Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
        end
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

      def wrap
        yield
      rescue Aws::S3::Errors::ServiceError => message
        failure(message)
      end

      def valid_object_identifier?(uuid)
        uuid.is_a?(String) && uuid.present?
      end

      def file_content(uuid)
        path = Tempfile.new("/#{SecureRandom.uuid}-", nil)
        object(uuid).get(response_target: path)
        data = File.binread(path)
        File.unlink(path)
        Atlas::Repository::RepositoryResponse.new(data: data, success: true)
      end

      def file_handle(uuid)
        path = Tempfile.new("/#{SecureRandom.uuid}-", nil)
        object(uuid).get(response_target: path)
        data = File.open(path, File::RDONLY | File::BINARY)
        Atlas::Repository::RepositoryResponse.new(data: data, success: true)
      end

      def upload(content, dest)
        src = make_tmp(content)
        object(dest).upload_file(src)
        File.unlink(src)
      end

      def object(remote_path)
        Aws::S3::Resource.new
                         .bucket(bucket_name)
                         .object("#{base_folder}#{remote_path}")
      end

      def make_tmp(content)
        Tempfile.new.tap do |tempfile|
          tempfile.write(content)
          tempfile.close
        end.path
      end

      def failure
        @notifier.send_error(message)
        Atlas::Repository::RepositoryResponse.new(data: nil, success: false)
      end
    end
  end
end
