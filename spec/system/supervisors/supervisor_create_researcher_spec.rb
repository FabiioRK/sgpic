require 'rails_helper'

RSpec.describe 'Supervisor criando pesquisador', type: :system do
  let!(:supervisor) { create(:user, :supervisor) }
  let!(:researcher_params) do
    {
      name: 'Ana Costa',
      phone_number: '(21) 98765-4321',
      academic_field: 'Biotecnologia',
      cv_link: 'http://example.com/cv.pdf',
      orcid_id: '0000-0002-1825-0097',
      academic_title: 'Mestre',
      email: 'ana.costa@example.com',
      password: 'senha123',
      password_confirmation: 'senha123',
      address_attributes: {
        postal_code: '12345-678',
        street: 'Rua Nova',
        district: 'Bairro Novo',
        complement: 'Casa 101',
        city: 'Rio de Janeiro',
        state: 'RJ'
      }
    }
  end

  before do
    login_as supervisor, scope: :user
  end

  describe 'Acessando a página de criação de pesquisador' do
    it 'permite que o supervisor acesse a página de criação de pesquisador' do
      visit new_researcher_registration_path

      expect(page).to have_content('Informações do pesquisador')
      expect(page).to have_content('Endereço')
      expect(page).to have_content('Credenciais')
    end
  end

  describe 'Criando um novo pesquisador' do
    it 'permite que o supervisor crie um pesquisador com sucesso' do
      visit new_researcher_registration_path

      fill_in 'Nome', with: researcher_params[:name]
      fill_in 'Telefone', with: researcher_params[:phone_number]
      fill_in 'Campo acadêmico', with: researcher_params[:academic_field]
      fill_in 'Link do currículo', with: researcher_params[:cv_link]
      fill_in 'ORCID', with: researcher_params[:orcid_id]
      fill_in 'Título acadêmico', with: researcher_params[:academic_title]
      fill_in 'E-mail', with: researcher_params[:email]
      fill_in 'Senha', with: researcher_params[:password]
      fill_in 'Confirme sua senha', with: researcher_params[:password_confirmation]
      fill_in 'CEP', with: researcher_params[:address_attributes][:postal_code]
      fill_in 'Rua', with: researcher_params[:address_attributes][:street]
      fill_in 'Bairro', with: researcher_params[:address_attributes][:district]
      fill_in 'Complemento', with: researcher_params[:address_attributes][:complement]
      fill_in 'Cidade', with: researcher_params[:address_attributes][:city]
      fill_in 'Estado', with: researcher_params[:address_attributes][:state]

      click_button 'Cadastrar'

      expect(page).to have_content('Cadastro de pesquisador realizado com sucesso.')
    end
  end

  describe 'Erros ao criar pesquisador' do
    it 'não permite criar pesquisador com informações inválidas' do
      visit new_researcher_registration_path

      fill_in 'Nome', with: ''
      fill_in 'Telefone', with: researcher_params[:phone_number]
      fill_in 'Campo acadêmico', with: researcher_params[:academic_field]
      fill_in 'Link do currículo', with: researcher_params[:cv_link]
      fill_in 'ORCID', with: researcher_params[:orcid_id]
      fill_in 'Título acadêmico', with: researcher_params[:academic_title]
      fill_in 'E-mail', with: researcher_params[:email]
      fill_in 'Senha', with: researcher_params[:password]
      fill_in 'Confirme sua senha', with: researcher_params[:password_confirmation]
      fill_in 'CEP', with: researcher_params[:address_attributes][:postal_code]
      fill_in 'Rua', with: researcher_params[:address_attributes][:street]
      fill_in 'Bairro', with: researcher_params[:address_attributes][:district]
      fill_in 'Complemento', with: researcher_params[:address_attributes][:complement]
      fill_in 'Cidade', with: researcher_params[:address_attributes][:city]
      fill_in 'Estado', with: researcher_params[:address_attributes][:state]

      click_button 'Cadastrar'

      expect(page).to have_content('Verifique os erros abaixo:')
      expect(page).to have_content("Nome não pode ficar em branco")
    end
  end
end
