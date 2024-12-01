FactoryBot.define do
  factory :notice_history do
    association :notice
    association :user, factory: :user
    changes_made { "Alteração no campo X." }
    edited_at { Time.current }
  end
end
