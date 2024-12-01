FactoryBot.define do
  factory :address do
    street { "Rua Teste" }
    district { "Bairro Teste" }
    complement { "Apto 101" }
    postal_code { "12345-678" }
    city { "Cidade Teste" }
    state { "Estado Teste" }
  end
end
