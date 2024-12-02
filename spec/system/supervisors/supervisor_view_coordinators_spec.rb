require 'rails_helper'

RSpec.describe 'Supervisor visualizando coordenadores', type: :system do
  let!(:user) { create(:user, :supervisor) }
  let!(:supervisor) { create(:supervisor, user: user) }
  let!(:coordinator1_user) { create(:user, :coordinator, active: true) }
  let!(:coordinator2_user) { create(:user, :coordinator, active: false) }
  let!(:coordinator1) { create(:coordinator, user: coordinator1_user) }
  let!(:coordinator2) { create(:coordinator, user: coordinator2_user) }

  before do
    login_as user, scope: :user
  end

  describe 'Acessando a página de coordenadores' do
    it 'permite que o supervisor veja a lista de coordenadores' do
      visit coordinators_path

      expect(page).to have_content('Lista de Coordenadores')
      expect(page).to have_content(coordinator1.name)
      expect(page).to have_content(coordinator2.name)
      expect(page).to have_content(coordinator1.user.email)
      expect(page).to have_content(coordinator2.user.email)
      expect(page).to have_selector('.coordinator-table')
    end
  end

  describe 'Verificando status dos coordenadores' do
    it 'exibe o status "Ativo" para coordenadores ativos' do
      visit coordinators_path

      expect(page).to have_selector('.badge.bg-success', text: 'Ativo')
    end

    it 'exibe o status "Inativo" para coordenadores inativos' do
      visit coordinators_path

      expect(page).to have_selector('.badge.bg-danger', text: 'Inativo')
    end
  end

  describe 'Ações dos coordenadores' do
    it 'permite visualizar um coordenador' do
      visit coordinators_path

      within("tr[data-coordinator-id='#{coordinator1.id}']") do
        click_link 'Visualizar'
      end

      expect(page).to have_content(coordinator1.name)
      expect(page).to have_content(coordinator1.user.email)
    end

    it 'permite desativar um coordenador ativo' do
      visit coordinators_path

      click_link 'Desativar'

      expect(page).to have_content('Coordenador desativado com sucesso')
      expect(coordinator1_user.reload.active?).to be_falsey
    end

    it 'permite ativar um coordenador inativo' do
      visit coordinators_path

      click_link 'Ativar'

      expect(page).to have_content('Coordenador ativado com sucesso')
      expect(coordinator2_user.reload.active?).to be_truthy
    end
  end

  describe 'Paginação da lista de coordenadores' do
    it 'mostra a paginação se houver mais de um coordenador' do
      visit coordinators_path

      expect(page).to have_selector('.pagination')
    end
  end
end
