require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validações' do
    it 'não é válido sem email' do
      user = build(:user, email: nil)
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("não pode ficar em branco")
    end

    it 'não é válido sem senha' do
      user = build(:user, password: nil)
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("não pode ficar em branco")
    end

    it 'não é válido sem cargo (role)' do
      user = build(:user, role: nil)
      expect(user).to_not be_valid
      expect(user.errors[:role]).to include("não pode ficar em branco")
    end

    it 'não permite emails duplicados' do
      create(:user, email: 'teste@exemplo.com', role: "supervisor")
      user = build(:user, email: 'teste@exemplo.com', role: "researcher")
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("já está em uso")
    end
  end

  describe 'associações' do
    it { should have_one(:supervisor).dependent(:destroy) }
    it { should have_one(:coordinator).dependent(:destroy) }
    it { should have_one(:researcher).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'callbacks' do
    context 'criação de associações automáticas' do
      it 'cria supervisors para usuário com cargo supervisors' do
        user = create(:user, :supervisor)
        expect(user.supervisor).to_not be_nil
        expect(user.supervisor.name).to eq("Supervisor Teste")
      end

      it 'não cria supervisors para usuário com outro cargo' do
        user = create(:user, :researcher)
        expect(user.supervisor).to be_nil
      end
    end
  end

  describe 'métodos' do
    let(:supervisor) { create(:supervisor, user: create(:user, :supervisor), name: 'Supervisor Teste') }
    let(:coordinator) { create(:coordinator, user: create(:user, :coordinator), name: 'Coordenador Teste') }

    it 'retorna display_name para supervisores' do
      user = supervisor.user
      expect(user.display_name).to eq('Supervisor Teste')
    end

    it 'retorna display_name para coordenadores' do
      user = coordinator.user
      expect(user.display_name).to eq('Coordenador Teste')
    end

    it 'identifica corretamente se é supervisors' do
      user = build(:user, :supervisor)
      expect(user.supervisor?).to be true
    end

    it 'identifica corretamente se não é supervisors' do
      user = build(:user, :researcher)
      expect(user.supervisor?).to be false
    end
  end
end
