# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Error
        module Wrap
          private

          ERR_CODE_MAPPING = [
            { match: /^E11000/, code: Enum::ErrorCodes::DOCUMENT_ALREADY_EXISTS }
          ].freeze

          DEFAULT_ERR_CODE = Enum::ErrorCodes::REPOSITORY_INTERNAL

          def wrap
            yield
          rescue Mongo::Error::OperationFailure => op_failure_err
            error(op_failure_err, code: error_code_from_opfail(op_failure_err))
          rescue Mongoid::Errors::DocumentNotFound => error
            error(error, false, code: Enum::ErrorCodes::DOCUMENT_NOT_FOUND)
          rescue Mongoid::Errors::MongoidError => internal_err
            error(internal_err)
          end

          def error(message, code: DEFAULT_ERR_CODE)
            notifier.send_error(message) if code == DEFAULT_ERR_CODE
            Atlas::Repository::RepositoryResponse.new(data: { base: message }, err_code: code)
          end

          def error_code_from_opfail(op_failure_err)
            message = op_failure_err.message
            specific_code = ERR_CODE_MAPPING.find { |map| message.match(map[:match]) }.try(:[], :code)
            specific_code || DEFAULT_ERR_CODE
          end
        end
      end
    end
  end
end
