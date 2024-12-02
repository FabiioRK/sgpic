require 'rails_helper'

RSpec.describe 'Supervisor visualizando pesquisadores', type: :system do
  let!(:user) { create(:user, :supervisor) }
  let!(:supervisor) { create(:supervisor, user: user) }
  let!(:researcher1_user) { create(:user, :researcher, active: true) }
  let!(:researcher2_user) { create(:user, :researcher, active: false) }
  let!(:researcher1) { create(:researcher, user: researcher1_user) }
  let!(:researcher2) { create(:researcher, user: researcher2_user) }

  before do
    login_as user, scope: :user
  end

  describe 'Acessando a página de pesquisadores' do
    it 'permite que o supervisor veja a lista de pesquisadores' do
      visit researchers_path

      expect(page).to have_content('Lista de Pesquisadores')
      expect(page).to have_content(researcher1.name)
      expect(page).to have_content(researcher2.name)
      expect(page).to have_content(researcher1.user.email)
      expect(page).to have_content(researcher2.user.email)
      expect(page).to have_selector('.researcher-table')
    end
  end

  describe 'Verificando status dos pesquisadores' do
    it 'exibe o status "Ativo" para pesquisadores ativos' do
      visit researchers_path

      expect(page).to have_selector('.badge.bg-success', text: 'Ativo')
    end

    it 'exibe o status "Inativo" para pesquisadores inativos' do
      visit researchers_path

      expect(page).to have_selector('.badge.bg-danger', text: 'Inativo')
    end
  end

  describe 'Ações dos pesquisadores' do
    it 'permite visualizar um pesquisador' do
      visit researchers_path

      within("tr[data-researcher-id='#{researcher1.id}']") do
        click_link 'Visualizar'
      end

      expect(page).to have_content(researcher1.name)
      expect(page).to have_content(researcher1.user.email)
    end

    it 'permite desativar um pesquisador ativo' do
      visit researchers_path

      click_link 'Desativar'

      expect(page).to have_content('Pesquisador desativado com sucesso')
      expect(researcher1_user.reload.active?).to be_falsey
    end

    it 'permite ativar um pesquisador inativo' do
      visit researchers_path

      click_link 'Ativar'

      expect(page).to have_content('Pesquisador ativado com sucesso')
      expect(researcher2_user.reload.active?).to be_truthy
    end
  end

  describe 'Paginação da lista de pesquisadores' do
    it 'mostra a paginação se houver mais de um pesquisador' do
      visit researchers_path

      expect(page).to have_selector('.pagination')
    end
  end
end
