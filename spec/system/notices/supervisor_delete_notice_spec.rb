require 'rails_helper'

RSpec.describe 'Supervisor deleting a notice', type: :system do
  let!(:user) { create(:user, :supervisor) }
  let!(:supervisor) { create(:supervisor, user: user) }
  let!(:notice) { create(:notice, active: true, user: create(:user, :supervisor)) }

  before do
    login_as user, scope: :user
  end

  it 'permite excluir um edital ativo' do
    visit notice_path(id: EncryptionService.encrypt(notice.id))

    expect(page).to have_link('Excluir')
    click_link 'Excluir'

    expect(page).to have_content('Edital excluído com sucesso.')
    expect(Notice.exists?(notice.id)).to be false
  end

  it 'não permite excluir um edital vinculado a um projeto' do
    create(:project, notice: notice)
    visit notice_path(id: EncryptionService.encrypt(notice.id))

    expect(page).to have_link('Excluir')
    click_link 'Excluir'

    expect(page).to have_content('Não é possível excluir o edital porque ele está vinculado a projetos.')
    expect(Notice.exists?(notice.id)).to be true
  end
end
