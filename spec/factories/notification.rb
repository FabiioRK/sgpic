FactoryBot.define do
  factory :notification do
    message { "Teste de notificação" }
    read { false }
    association :user, factory: :user, role: :supervisor
    association :project
  end
end
