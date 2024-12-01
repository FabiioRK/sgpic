require 'rails_helper'

RSpec.describe NoticeHistory, type: :model do
  describe 'validações' do
    let(:user) { create(:user, :coordinator) }
    let(:notice) { create(:notice, user: user) }

    it 'é válido com atributos válidos' do
      notice_history = build(:notice_history, notice: notice, user: user, changes_made: 'Alteração de descrição', edited_at: Time.current)
      expect(notice_history).to be_valid
    end

    it 'não é válido sem um usuário (edited_by)' do
      notice_history = build(:notice_history, notice: notice, user: nil)
      expect(notice_history).to_not be_valid
      expect(notice_history.errors[:edited_by]).to include("não pode ficar em branco")
    end

    it 'não é válido sem alterações feitas (changes_made)' do
      notice_history = build(:notice_history, notice: notice, user: user, changes_made: nil)
      expect(notice_history).to_not be_valid
      expect(notice_history.errors[:changes_made]).to include("não pode ficar em branco")
    end

    it 'não é válido sem a data de edição (edited_at)' do
      notice_history = build(:notice_history, notice: notice, user: user, edited_at: nil)
      expect(notice_history).to_not be_valid
      expect(notice_history.errors[:edited_at]).to include("não pode ficar em branco")
    end
  end

  describe 'associações' do
    it { should belong_to(:notice) }
    it { should belong_to(:user).with_foreign_key('edited_by') }
  end
end
