# frozen_string_literal: true

FactoryGirl.define do
  factory :query_result, class: Atlas::Service::Mechanism::Pagination::QueryResult do
    total { results.try(:length) || 0 }
    per_page { results.try(:length) || 0 }
  end

  factory :repository_response, class: Atlas::Repository::RepositoryResponse do
    data { Object.new }

    trait :success do
      success true
    end

    trait :failure do
      success false
    end
  end

  factory :request_context, class: Atlas::Service::RequestContext do
    time { Time.now.utc }
    component 'Shared Example Component'
    caller { 'Shared Examples' }
    transaction_id { SecureRandom.uuid }
    account_id { SecureRandom.uuid }
    authentication_type :system
  end

  factory :service_response, class: Atlas::Service::ServiceResponse do
    trait :success do
      data { Object.new }
      code Atlas::Enum::ErrorCodes::NONE
      message nil
    end

    trait :failure do
      data({})
      code Atlas::Enum::ErrorCodes::INTERNAL
      message 'Fake Error'
    end

    trait :unauthorized do
      data({})
      code Atlas::Enum::ErrorCodes::PERMISSION_ERROR
      message 'Unauthorized'
    end
  end
end
