FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "senha123" }

    trait :supervisor do
      role { "supervisor" }
    end

    trait :coordinator do
      role { "coordinator" }
    end

    trait :researcher do
      role { "researcher" }
    end
  end
end
