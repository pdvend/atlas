FactoryGirl.define do
  factory :query_result, class: Atlas::Service::Mechanism::Pagination::QueryResult do
    total { results.try(:length) || 0 }
    per_page { results.try(:length) || 0 }
  end
end
