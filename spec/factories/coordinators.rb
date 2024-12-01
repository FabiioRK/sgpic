FactoryBot.define do
  factory :coordinator do
    name { "Coordenador Teste" }
    academic_field { "Área Acadêmica Teste" }
    phone_number { "(11) 98765-4321" }
    user { create(:user, :coordinator) }
    address
  end
end
