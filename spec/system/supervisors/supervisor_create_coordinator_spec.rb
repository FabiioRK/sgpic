require 'rails_helper'

RSpec.describe 'Supervisor criando coordenador', type: :system do
  let!(:supervisor) { create(:user, :supervisor) }
  let!(:coordinator_params) do
    {
      name: 'João Silva',
      phone_number: '(11) 98765-4321',
      academic_field: 'Ciências Sociais',
      email: 'joao.silva@example.com',
      password: 'senha123',
      password_confirmation: 'senha123',
      address_attributes: {
        postal_code: '12345-678',
        street: 'Rua Exemplo',
        district: 'Bairro Exemplo',
        complement: 'Apartamento 101',
        city: 'São Paulo',
        state: 'SP'
      }
    }
  end

  before do
    login_as supervisor, scope: :user
  end

  describe 'Acessando a página de criação de coordenador' do
    it 'permite que o supervisor acesse a página de criação de coordenador' do
      visit new_coordinator_registration_path

      expect(page).to have_content('Informações do coordenador')
      expect(page).to have_content('Endereço')
      expect(page).to have_content('Credenciais')
    end
  end

  describe 'Criando um novo coordenador' do
    it 'permite que o supervisor crie um coordenador com sucesso' do
      visit new_coordinator_registration_path

      fill_in 'Nome', with: coordinator_params[:name]
      fill_in 'Telefone', with: coordinator_params[:phone_number]
      fill_in 'Campo acadêmico', with: coordinator_params[:academic_field]
      fill_in 'E-mail', with: coordinator_params[:email]
      fill_in 'Senha', with: coordinator_params[:password]
      fill_in 'Confirme sua senha', with: coordinator_params[:password_confirmation]
      fill_in 'CEP', with: coordinator_params[:address_attributes][:postal_code]
      fill_in 'Rua', with: coordinator_params[:address_attributes][:street]
      fill_in 'Bairro', with: coordinator_params[:address_attributes][:district]
      fill_in 'Complemento', with: coordinator_params[:address_attributes][:complement]
      fill_in 'Cidade', with: coordinator_params[:address_attributes][:city]
      fill_in 'Estado', with: coordinator_params[:address_attributes][:state]

      click_button 'Cadastrar'

      expect(page).to have_content('Cadastro de coordenador realizado com sucesso.')
    end
  end

  describe 'Erros ao criar coordenador' do
    it 'não permite criar coordenador com informações inválidas' do
      visit new_coordinator_registration_path

      fill_in 'Nome', with: ''
      fill_in 'Telefone', with: coordinator_params[:phone_number]
      fill_in 'Campo acadêmico', with: coordinator_params[:academic_field]
      fill_in 'E-mail', with: coordinator_params[:email]
      fill_in 'Senha', with: coordinator_params[:password]
      fill_in 'Confirme sua senha', with: coordinator_params[:password_confirmation]
      fill_in 'CEP', with: coordinator_params[:address_attributes][:postal_code]
      fill_in 'Rua', with: coordinator_params[:address_attributes][:street]
      fill_in 'Bairro', with: coordinator_params[:address_attributes][:district]
      fill_in 'Complemento', with: coordinator_params[:address_attributes][:complement]
      fill_in 'Cidade', with: coordinator_params[:address_attributes][:city]
      fill_in 'Estado', with: coordinator_params[:address_attributes][:state]

      click_button 'Cadastrar'

      expect(page).to have_content('Verifique os erros abaixo:')
      expect(page).to have_content("Nome não pode ficar em branco")
    end
  end
end
