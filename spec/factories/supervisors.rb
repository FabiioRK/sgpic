FactoryBot.define do
  factory :supervisor do
    name { "Supervisor Teste" }
    user { create(:user, :supervisor) }
  end
end
