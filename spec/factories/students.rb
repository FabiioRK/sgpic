FactoryBot.define do
  factory :student do
    name { Faker::Name.name }
    social_security_number { '123.456.789-00' }
    identity_card_number { '123456789' }
    birth_date { Date.today - 20.years }
    phone_number { '(11) 98765-4321' }
    email { Faker::Internet.email }
    academic_field { Faker::Educator.subject }
    course { Faker::Educator.course }
    semester { rand(1..10) }
    has_subject_dependencies { false }
    is_regular_student { true }
    project
    association :address, factory: :address
  end
end
