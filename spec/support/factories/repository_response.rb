FactoryGirl.define do
  factory :repository_response, class: Atlas::Repository::RepositoryResponse do
    data { Object.new }

    trait :success do
      success true
    end

    trait :failure do
      success false
    end
  end
end
