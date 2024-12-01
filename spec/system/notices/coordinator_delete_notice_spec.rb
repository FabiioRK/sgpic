require 'rails_helper'

RSpec.describe 'Coordinator deleting a notice', type: :system do
  let!(:user) { create(:user, :coordinator) }
  let!(:coordinator) { create(:coordinator, user: user) }
  let!(:notice) { create(:notice, active: true, user: create(:user, :coordinator)) }
  let!(:notice_linked) { create(:notice, active: true, user: create(:user, :coordinator)) }
  let!(:projeto) { create(:project, notice: notice_linked) }

  before do
    login_as user, scope: :user
  end

  context 'when the notice does not belong to a project' do
    it 'allows the coordinator to delete the notice' do
      visit notice_path(notice)

      expect(page).to have_link('Excluir')
      click_link 'Excluir'

      expect(page).to have_content('Edital excluído com sucesso.')
      expect(Notice.exists?(notice.id)).to be false
    end
  end

  context 'when the notice belongs to a project' do
    it 'does not allow the coordinator to delete the notice' do
      visit notice_path(notice_linked)

      expect(page).to have_link('Excluir')
      click_link 'Excluir'

      expect(page).to have_content('Não é possível excluir o edital porque ele está vinculado a projetos.')
      expect(Notice.exists?(notice_linked.id)).to be true
    end
  end
end
