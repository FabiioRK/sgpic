require 'rails_helper'

RSpec.describe 'Coordinator activating or deactivating a notice', type: :system do
  let!(:user) { create(:user, :coordinator) }
  let!(:coordinator) { create(:coordinator, user: user) }
  let!(:notice_active) { create(:notice, active: true, user: create(:user, :coordinator)) }
  let!(:notice_inactive) { create(:notice, active: false, user: create(:user, :coordinator)) }

  before do
    login_as user, scope: :user
  end

  context 'when the notice is active' do
    it 'allows the coordinator to deactivate the notice' do
      visit notice_path(id: EncryptionService.encrypt(notice_active.id))

      expect(page).to have_content('Ativo')
      expect(page).to have_link('Desativar')
      click_link 'Desativar'

      expect(page).to have_content('Status do edital atualizado com sucesso.')
      expect(Notice.find(notice_active.id).active).to be false
    end
  end

  context 'when the notice is inactive' do
    it 'allows the coordinator to activate the notice' do
      visit notice_path(id: EncryptionService.encrypt(notice_inactive.id))

      expect(page).to have_content('Inativo')
      expect(page).to have_link('Ativar')
      click_link 'Ativar'

      expect(page).to have_content('Status do edital atualizado com sucesso.')
      expect(Notice.find(notice_inactive.id).active).to be true
    end
  end
end
