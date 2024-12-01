FactoryBot.define do
  factory :annotation_history do
    association :project
    association :user, factory: :user, role: :coordinator
    annotation { "Texto da anotação de teste" }
  end
end
