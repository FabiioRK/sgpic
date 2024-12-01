require 'rails_helper'

RSpec.describe Notice, type: :model do
  describe 'validações' do
    let(:user) { create(:user, :coordinator) }

    it 'é válido com atributos válidos' do
      notice = build(:notice, user: user)
      expect(notice).to be_valid
    end

    it 'não é válido sem um nome' do
      notice = build(:notice, name: nil, user: user)
      expect(notice).to_not be_valid
      expect(notice.errors[:name]).to include("não pode ficar em branco")
    end

    it 'não é válido sem uma data de início' do
      notice = build(:notice, start_date: nil, user: user)
      expect(notice).to_not be_valid
      expect(notice.errors[:start_date]).to include("não pode ficar em branco")
    end

    it 'não é válido sem uma data de término' do
      notice = build(:notice, end_date: nil, user: user)
      expect(notice).to_not be_valid
      expect(notice.errors[:end_date]).to include("não pode ficar em branco")
    end

    it 'não é válido sem uma descrição' do
      notice = build(:notice, description: nil, user: user)
      expect(notice).to_not be_valid
      expect(notice.errors[:description]).to include("não pode ficar em branco")
    end

    it 'não é válido se o nome tiver mais de 255 caracteres' do
      notice = build(:notice, name: 'A' * 256, user: user)
      expect(notice).to_not be_valid
      expect(notice.errors[:name]).to include("é muito longo (máximo: 255 caracteres)")
    end

    it 'não é válido se a data de início for maior que a data de término' do
      notice = build(:notice, start_date: Date.today + 5.days, end_date: Date.today + 3.days, user: user)
      expect(notice).to_not be_valid
      expect(notice.errors[:base]).to include("A data de início não pode ser maior que a data final.")
    end

    it 'não permite reativar um edital expirado' do
      notice = create(:notice, start_date: Date.today + 1.day, end_date: Date.today + 5.days, active: true, user: user)

      notice.update!(start_date: Date.today - 10.days, end_date: Date.today - 5.days, active: false)

      notice.active = true
      expect(notice).to_not be_valid
      expect(notice.errors[:base]).to include("Não é possível reativar um edital cuja data final já passou.")
    end


    it 'não é válido se a data de início for no passado para um novo registro' do
      notice = build(:notice, start_date: Date.today - 1.day, user: user)
      expect(notice).to_not be_valid
      expect(notice.errors[:base]).to include("A data de início deve ser futura.")
    end
  end

  describe 'associações' do
    it { should belong_to(:user).with_foreign_key(:created_by) }
    it { should have_many(:notice_histories).dependent(:destroy) }
    it { should have_many(:projects) }
  end

  describe 'callbacks' do
    let(:user) { create(:user, :coordinator) }

    it 'desativa o edital automaticamente se a data de término for no passado' do
      notice = create(:notice, start_date: Date.today + 10.days, end_date: Date.today + 15.days, user: user, active: true)

      notice.update!(start_date: Date.today - 10.days, end_date: Date.today - 1.day)

      notice.reload
      expect(notice.active).to be_falsey
    end


    it 'não desativa um edital cuja data de término ainda está no futuro' do
      notice = create(:notice, start_date: Date.today, end_date: Date.today + 5.days, user: user)
      expect(notice.active).to eq(true)
    end
  end

  describe 'métodos de classe' do
    let(:user) { create(:user, :coordinator) }

    it 'desativa editais expirados' do
      notice = create(:notice, start_date: Date.today + 10.days, end_date: Date.today + 15.days, active: true, user: user)

      notice.update!(start_date: Date.today - 10.days, end_date: Date.today - 1.day)

      Notice.deactivate_expired

      notice.reload
      expect(notice.active).to be_falsey
    end
  end
end
