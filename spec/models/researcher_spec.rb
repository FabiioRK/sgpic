require 'rails_helper'

RSpec.describe Researcher, type: :model do
  describe 'validações' do
    it 'é válido com atributos válidos' do
      researcher = build(:researcher,
                         name: 'Pesquisador Teste',
                         academic_field: 'Ciência da Computação',
                         cv_link: 'http://lattes.cnpq.br/1234567890',
                         orcid_id: '0000-0001-2345-6789',
                         academic_title: 'Doutor',
                         phone_number: '(11) 98765-4321',
                         user: create(:user, :researcher))
      expect(researcher).to be_valid
    end

    it 'não é válido sem um nome' do
      researcher = build(:researcher, name: nil, user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:name]).to include("não pode ficar em branco")
    end

    it 'não é válido sem uma área acadêmica' do
      researcher = build(:researcher, academic_field: nil, user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:academic_field]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um link do currículo' do
      researcher = build(:researcher, cv_link: nil, user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:cv_link]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um ID ORCID' do
      researcher = build(:researcher, orcid_id: nil, user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:orcid_id]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um título acadêmico' do
      researcher = build(:researcher, academic_title: nil, user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:academic_title]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um número de telefone' do
      researcher = build(:researcher, phone_number: nil, user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:phone_number]).to include("não pode ficar em branco")
    end

    it 'não é válido com um número de telefone em formato inválido' do
      researcher = build(:researcher, phone_number: '12345-6789', user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:phone_number]).to include("deve estar no formato (XX) XXXXX-XXXX")
    end

    it 'não é válido com um número de telefone de tamanho inválido' do
      researcher = build(:researcher, phone_number: '(11) 1234-567', user: create(:user, :researcher))
      expect(researcher).to_not be_valid
      expect(researcher.errors[:phone_number]).to include("deve estar no formato (XX) XXXXX-XXXX")
    end

    it 'não é válido sem um usuário associado' do
      researcher = build(:researcher, user: nil)
      expect(researcher).to_not be_valid
      expect(researcher.errors[:user]).to_not be_empty
    end
  end

  describe 'associações' do
    it { should belong_to(:user) }
    it { should have_one(:address) }
    it { should have_many(:projects) }
  end

  describe 'atributos aninhados' do
    it { should accept_nested_attributes_for(:projects) }
    it { should accept_nested_attributes_for(:address) }
  end

  describe 'criação de registros' do
    it 'cria um pesquisador com atributos válidos e um usuário associado' do
      user = create(:user, :researcher)
      researcher = create(:researcher,
                          name: 'Pesquisador Teste',
                          academic_field: 'Ciência da Computação',
                          cv_link: 'http://lattes.cnpq.br/1234567890',
                          orcid_id: '0000-0001-2345-6789',
                          academic_title: 'Doutor',
                          phone_number: '(11) 98765-4321',
                          user: user)
      expect(researcher.user).to eq(user)
    end

    it 'cria um endereço associado ao pesquisador se fornecido' do
      address = create(:address)
      researcher = create(:researcher,
                          name: 'Pesquisador Teste',
                          academic_field: 'Ciência da Computação',
                          cv_link: 'http://lattes.cnpq.br/1234567890',
                          orcid_id: '0000-0001-2345-6789',
                          academic_title: 'Doutor',
                          phone_number: '(11) 98765-4321',
                          address: address,
                          user: create(:user, :researcher))
      expect(researcher.address).to eq(address)
    end
  end
end
