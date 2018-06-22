# frozen_string_literal: true

module Atlas
  module Repository
    class FileStorageRepository
      DEFAULT_ERR_CODE = Enum::ErrorCodes::REPOSITORY_INTERNAL

      def initialize(notifier:, base_path:)
        @notifier = notifier
        @base_path = base_path
      end

      def put(uuid, content)
        return failure unless valid_object_identifier?(uuid) && content.is_a?(String)

        wrap do
          save_file(content, uuid)
          Atlas::Repository::RepositoryResponse.new(data: nil, err_code: Enum::ErrorCodes::NONE)
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

      attr_accessor :notifier, :base_path

      def public_url(uuid, _expires_in)
        "#{base_path}/#{uuid}"
      end

      def wrap
        yield
      rescue StandardError
        failure(message: message, code: DEFAULT_ERR_CODE)
      end

      def valid_object_identifier?(uuid)
        uuid.is_a?(String) && uuid.present?
      end

      def file_content(uuid)
        data = File.binread("#{base_path}/#{uuid}")
        Atlas::Repository::RepositoryResponse.new(data: data, err_code: Enum::ErrorCodes::NONE)
      end

      def file_handle(uuid)
        data = File.open("#{base_path}/#{uuid}", File::RDONLY | File::BINARY)
        Atlas::Repository::RepositoryResponse.new(data: data, err_code: Enum::ErrorCodes::NONE)
      end

      def save_file(content, dest)
        File.binwrite("#{base_path}/#{dest}", content)
      end

      def failure(message: nil, code: DEFAULT_ERR_CODE)
        notifier.send_error(message) if code == DEFAULT_ERR_CODE && message.present?
        Atlas::Repository::RepositoryResponse.new(data: nil, err_code: code)
      end
    end
  end
end
