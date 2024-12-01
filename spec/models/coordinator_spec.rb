require 'rails_helper'

RSpec.describe Coordinator, type: :model do
  describe 'validações' do
    it 'é válido com atributos válidos' do
      coordinator = build(:coordinator,
                          name: 'Coordenador Teste',
                          academic_field: 'Ciência da Computação',
                          phone_number: '(11) 98765-4321',
                          user: create(:user, :coordinator))
      expect(coordinator).to be_valid
    end

    it 'não é válido sem um nome' do
      coordinator = build(:coordinator,
                          name: nil,
                          academic_field: 'Ciência da Computação',
                          phone_number: '(11) 98765-4321',
                          user: create(:user, :coordinator))
      expect(coordinator).to_not be_valid
      expect(coordinator.errors[:name]).to include("não pode ficar em branco")
    end

    it 'não é válido sem uma área acadêmica' do
      coordinator = build(:coordinator,
                          name: 'Coordenador Teste',
                          academic_field: nil,
                          phone_number: '(11) 98765-4321',
                          user: create(:user, :coordinator))
      expect(coordinator).to_not be_valid
      expect(coordinator.errors[:academic_field]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um número de telefone' do
      coordinator = build(:coordinator,
                          name: 'Coordenador Teste',
                          academic_field: 'Ciência da Computação',
                          phone_number: nil,
                          user: create(:user, :coordinator))
      expect(coordinator).to_not be_valid
      expect(coordinator.errors[:phone_number]).to include("não pode ficar em branco")
    end

    it 'não é válido com um número de telefone em formato inválido' do
      coordinator = build(:coordinator,
                          name: 'Coordenador Teste',
                          academic_field: 'Ciência da Computação',
                          phone_number: '12345-6789',
                          user: create(:user, :coordinator))
      expect(coordinator).to_not be_valid
      expect(coordinator.errors[:phone_number]).to include("deve estar no formato (XX) XXXXX-XXXX")
    end

    it 'não é válido com um número de telefone com tamanho inválido' do
      coordinator = build(:coordinator,
                          name: 'Coordenador Teste',
                          academic_field: 'Ciência da Computação',
                          phone_number: '(11) 1234-567',
                          user: create(:user, :coordinator))
      expect(coordinator).to_not be_valid
      expect(coordinator.errors[:phone_number]).to include("deve estar no formato (XX) XXXXX-XXXX")
    end

    it 'não é válido sem um usuário associado' do
      coordinator = build(:coordinator,
                          name: 'Coordenador Teste',
                          academic_field: 'Ciência da Computação',
                          phone_number: '(11) 98765-4321',
                          user: nil)
      expect(coordinator).to_not be_valid
      expect(coordinator.errors[:user]).to_not be_empty # Mensagem genérica
    end
  end

  describe 'associações' do
    it { should belong_to(:user) }
    it { should have_many(:projects) }
    it { should have_one(:address) }
  end

  describe 'atributos aninhados' do
    it { should accept_nested_attributes_for(:address) }
  end

  describe 'criação de registros' do
    it 'cria um coordenador com atributos válidos e um usuário associado' do
      user = create(:user, :coordinator)
      coordinator = create(:coordinator,
                           name: 'Coordenador Teste',
                           academic_field: 'Ciência da Computação',
                           phone_number: '(11) 98765-4321',
                           user: user)
      expect(coordinator.user).to eq(user)
    end

    it 'cria um endereço associado ao coordenador se fornecido' do
      address = create(:address)
      coordinator = create(:coordinator,
                           name: 'Coordenador Teste',
                           academic_field: 'Ciência da Computação',
                           phone_number: '(11) 98765-4321',
                           address: address,
                           user: create(:user, :coordinator))
      expect(coordinator.address).to eq(address)
    end
  end
end
