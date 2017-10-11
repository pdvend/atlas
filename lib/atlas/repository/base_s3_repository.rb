# frozen_string_literal: true

module Atlas
  module Repository
    class BaseS3Repository
      EMPTY_STRING = ''
      private_constant :EMPTY_STRING

      def put(uuid, content)
        return failure unless valid_put_params?(uuid, content)
        upload(make_tmp(content), uuid)
        Atlas::Repository::RepositoryResponse.new(data: nil, success: true)
      rescue Aws::S3::Errors::ServiceError
        failure
      end

      def get(uuid, content = true)
        return failure unless valid_object_identifier?(uuid)
        content ? file_content(uuid) : file_handle(uuid)
      rescue Aws::S3::Errors::ServiceError
        failure
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

      def valid_put_params?(uuid, content)
        valid_object_identifier?(uuid) && content.is_a?(String)
      end

      def valid_object_identifier?(uuid)
        uuid.is_a?(String) && uuid.present?
      end

      def file_content(uuid)
        handle_result = file_handle(uuid)
        return handle_result unless handle_result.success

        file = handle_result.data
        data = file.read
        file.close

        File.unlink(file.path)
        Atlas::Repository::RepositoryResponse.new(data: data, success: true)
      end

      def file_handle(uuid)
        path = Dir::Tmpname.make_tmpname("/tmp/#{SecureRandom.uuid}-", nil)
        object(uuid).get(response_target: path)
        data = File.open(path, File::RDONLY | File::BINARY)
        Atlas::Repository::RepositoryResponse.new(data: data, success: true)
      end

      def upload(src, dest)
        object(dest).upload_file(src)
        File.unlink(src)
      end

      def object(remote_path)
        bucket.object("#{base_folder}#{remote_path}")
      end

      def bucket
        s3.bucket(bucket_name)
      end

      def s3
        Aws::S3::Resource.new
      end

      def make_tmp(content)
        tempfile = Tempfile.new
        tempfile.write(content)
        tempfile.close
        tempfile.path
      end

      def failure
        Atlas::Repository::RepositoryResponse.new(data: nil, success: false)
      end
    end
  end
end
