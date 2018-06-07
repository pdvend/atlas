# frozen_string_literal: true

module Atlas
  module Service
    class RequestContext < Atlas::Entity::BaseEntity
      parameters :time, :component, :caller, :transaction_id, :account_id, :authentication_type,
                 :user, :company

      AUTHENTICATION_TYPES = %i[user none system].freeze
      schema do
        required(:time).filled(:date_time?)
        required(:component).filled(:str?)
        required(:caller).filled(:str?)
        required(:transaction_id) { filled? & str? & format?(Atlas::Enum::Formats::UUID4) }
        required(:account_id) { filled? > (str? &  format?(Atlas::Enum::Formats::UUID4)) }
        required(:authentication_type).filled(type?: Symbol, included_in?: AUTHENTICATION_TYPES)
        required(:user).maybe(:hash?)
        required(:company).maybe(:hash?)

        rule(user_presence: %i[authentication_type, user]) do |authentication_type, user|
          authentication_type.eql?(:user) > user.filled?
        end

        rule(company_presence: %i[authentication_type, company]) do |authentication_type, company|
          authentication_type.eql?(:user) > company.filled?
        end
      end

      def to_event
        base_event = to_h
        base_event.delete(:time)
        base_event.merge(start_time: time.iso8601, elapsed_time: Time.now.utc - time.utc)
      end

      def user?
        authentication_type == :user
      end

      def system?
        authentication_type == :system
      end

      def authenticated?
        user? || system?
      end

      def unauthenticated?
        !authenticated?
      end
    end
  end
end
