require 'rails_helper'

RSpec.describe Supervisor, type: :model do
  describe 'validações' do
    it 'é válido com atributos válidos' do
      supervisor = build(:supervisor, name: 'Supervisor Teste', user: create(:user, :supervisor))
      expect(supervisor).to be_valid
    end

    it 'não é válido sem um nome' do
      supervisor = build(:supervisor, name: nil, user: create(:user, :supervisor))
      expect(supervisor).to_not be_valid
      expect(supervisor.errors[:name]).to include("não pode ficar em branco")
    end

    it 'não é válido com um nome muito longo' do
      supervisor = build(:supervisor, name: 'A' * 256, user: create(:user, :supervisor))
      expect(supervisor).to_not be_valid
      expect(supervisor.errors[:name]).to include("é muito longo (máximo: 255 caracteres)")
    end

    it 'não é válido sem um usuário associado' do
      supervisor = build(:supervisor, name: 'Supervisor Teste', user: nil)
      expect(supervisor).to_not be_valid
      expect(supervisor.errors[:user]).to include("é obrigatório(a)")
    end
  end

  describe 'associações' do
    it { should belong_to(:user) }
    it { should have_one(:address) }
  end

  describe 'atributos aninhados' do
    it { should accept_nested_attributes_for(:address) }
  end

  describe 'criação de registros' do
    it 'cria um endereço associado se fornecido' do
      supervisor = create(:supervisor, user: create(:user, :supervisor), address: build(:address))
      expect(supervisor.address).to_not be_nil
    end

    it 'não cria um endereço se não fornecido' do
      supervisor = create(:supervisor, user: create(:user, :supervisor))
      expect(supervisor.address).to be_nil
    end
  end
end
