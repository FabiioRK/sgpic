require 'rails_helper'

RSpec.describe 'Coordinator creating a notice', type: :system do
  let!(:user) { create(:user, :coordinator) }
  let!(:coordinator) { create(:coordinator, user: user) }

  before do
    login_as user, scope: :user
    visit new_notice_path
  end

  describe 'Formulário de criação de edital' do
    context 'com dados válidos' do
      it 'cria um edital com sucesso' do
        fill_in 'notice[name]', with: 'Edital Teste'
        fill_in 'notice[start_date]', with: Date.today
        fill_in 'notice[end_date]', with: Date.today + 30.days
        fill_in 'notice[description]', with: 'Descrição do edital de teste.'
        click_button 'Salvar'

        expect(page).to have_content('Edital criado com sucesso')
        expect(Notice.count).to eq(1)
        notice = Notice.last
        expect(notice.name).to eq('Edital Teste')
        expect(notice.start_date).to eq(Date.today)
        expect(notice.end_date).to eq(Date.today + 30.days)
        expect(notice.description).to eq('Descrição do edital de teste.')
      end
    end

    context 'com dados inválidos' do
      it 'não cria um edital sem preencher campos obrigatórios' do
        click_button 'Salvar'

        expect(page).to have_content('Erro(s) ao salvar:')
        expect(page).to have_content('Nome não pode ficar em branco')
        expect(page).to have_content('Data de início não pode ficar em branco')
        expect(page).to have_content('Data final não pode ficar em branco')
        expect(page).to have_content('Descrição não pode ficar em branco')
        expect(Notice.count).to eq(0)
      end

      it 'não cria um edital com data final anterior à data de início' do
        fill_in 'notice[name]', with: 'Edital Inválido'
        fill_in 'notice[start_date]', with: Date.today
        fill_in 'notice[end_date]', with: Date.yesterday
        fill_in 'notice[description]', with: 'Descrição inválida.'
        click_button 'Salvar'

        expect(page).to have_content('Erro(s) ao salvar:')
        expect(page).to have_content('A data de início não pode ser maior que a data final.')
        expect(Notice.count).to eq(0)
      end
    end
  end
end