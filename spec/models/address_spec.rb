require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validações' do
    it 'é válido com atributos válidos' do
      address = build(:address, street: 'Rua Teste', district: 'Centro', postal_code: '12345-678', city: 'São Paulo', state: 'SP')
      expect(address).to be_valid
    end

    it 'não é válido sem atributos obrigatórios' do
      address = build(:address, street: nil, district: nil, postal_code: nil, city: nil, state: nil)
      expect(address).to_not be_valid
      expect(address.errors[:street]).to include("não pode ficar em branco")
      expect(address.errors[:district]).to include("não pode ficar em branco")
      expect(address.errors[:postal_code]).to include("não pode ficar em branco")
      expect(address.errors[:city]).to include("não pode ficar em branco")
      expect(address.errors[:state]).to include("não pode ficar em branco")
    end

    it 'não é válido com CEP no formato incorreto' do
      address = build(:address, postal_code: '12345678')
      expect(address).to_not be_valid
      expect(address.errors[:postal_code]).to include("deve estar no formato XXXXX-XXX")
    end
  end

  describe 'associações inversas' do
    it 'pode estar associado a um supervisors' do
      supervisor = create(:supervisor, address: create(:address))
      expect(supervisor.address).to be_present
    end

    it 'pode estar associado a um coordenador' do
      coordinator = create(:coordinator, address: create(:address))
      expect(coordinator.address).to be_present
    end

    it 'pode estar associado a um pesquisador' do
      researcher = create(:researcher, address: create(:address))
      expect(researcher.address).to be_present
    end
  end
end
