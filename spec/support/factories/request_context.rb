FactoryGirl.define do
  factory :request_context, class: Atlas::Service::RequestContext do
    time { Time.now.utc }
    component 'Shared Example Component'
    caller { 'Shared Examples' }
    transaction_id { SecureRandom.uuid }
    account_id { SecureRandom.uuid }
    authentication_type :system
  end
end
