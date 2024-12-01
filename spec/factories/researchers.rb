FactoryBot.define do
  factory :researcher do
    name { "Pesquisador Teste" }
    academic_field { "Área Acadêmica Teste" }
    phone_number { "(11) 91234-5678" }
    academic_title { "Doutor" }
    cv_link { "http://lattes.cnpq.br/1234567890" }
    orcid_id { "0000-0001-2345-6789" }
    user { create(:user, :researcher) }
    address
  end
end
