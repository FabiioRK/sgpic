require 'rails_helper'

RSpec.describe 'Usuário fazendo login', type: :system do
  let!(:user) { create(:user, email: 'teste@example.com', password: 'senha123', active: true, role: 'supervisor') }

  describe 'Acessando a página de login' do
    it 'exibe o formulário de login corretamente' do
      visit new_user_session_path

      expect(page).to have_content('Bem-vindo ao SGPIC')
      expect(page).to have_field('Digite seu email')
      expect(page).to have_field('Digite sua senha')
      expect(page).to have_button('Entrar')
    end
  end

  describe 'Fazendo login com credenciais válidas' do
    it 'permite que o usuário faça login com sucesso' do
      visit new_user_session_path

      fill_in 'Digite seu email', with: user.email
      fill_in 'Digite sua senha', with: user.password
      click_button 'Entrar'

      expect(page).to have_content('Login efetuado com sucesso.')
      expect(page).to have_current_path(root_path)
    end
  end

  describe 'Fazendo login com credenciais inválidas' do
    it 'exibe mensagem de erro para e-mail inválido' do
      visit new_user_session_path

      fill_in 'Digite seu email', with: 'email_invalido@example.com'
      fill_in 'Digite sua senha', with: user.password
      click_button 'Entrar'

      expect(page).to have_content('E-mail ou senha inválidos.')
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'exibe mensagem de erro para senha inválida' do
      visit new_user_session_path

      fill_in 'Digite seu email', with: user.email
      fill_in 'Digite sua senha', with: 'senha_invalida'
      click_button 'Entrar'

      expect(page).to have_content('E-mail ou senha inválidos.')
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe 'Tentando fazer login com um usuário inativo' do
    let!(:inactive_user) { create(:user, email: 'inativo@example.com', password: 'senha123', role: 'coordinator', active: false) }
    let!(:coordinator) { create(:coordinator, user: inactive_user) }

    it 'exibe mensagem de erro para usuário inativo' do
      visit new_user_session_path

      fill_in 'Digite seu email', with: inactive_user.email
      fill_in 'Digite sua senha', with: inactive_user.password
      click_button 'Entrar'

      visit coordinator_projects_path(coordinator.id)

      expect(page).to have_content('Acesso não autorizado')
      expect(page).to have_current_path(root_path)
    end
  end

  describe 'Deslogando do sistema' do
    it 'permite que o usuário faça logout com sucesso' do
      login_as user, scope: :user

      visit root_path
      click_link 'Sair'

      expect(page).to have_content('Sessão finalizada com sucesso.')
    end
  end
end
