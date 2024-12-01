FactoryBot.define do
  factory :notice do
    sequence(:name) { |n| "Edital de Teste #{n}" }
    description { "Descrição do edital de teste." }
    start_date { 2.days.from_now }
    end_date { 1.month.from_now }
    active { true }
    user { create(:user, :coordinator) }
  end
end
