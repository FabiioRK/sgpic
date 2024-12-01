require 'rails_helper'

RSpec.describe 'Supervisor editing a notice', type: :system do
  let!(:user) { create(:user, :supervisor) }
  let!(:supervisor) { create(:supervisor, user: user) }
  let!(:notice) { create(:notice, active: true, user: create(:user, :supervisor)) }

  before do
    login_as user, scope: :user
    visit edit_notice_path(notice)
  end

  it 'exibe o formulário de edição do edital com os dados corretos' do
    expect(page).to have_field('Nome', with: notice.name)
    expect(page).to have_field('Data de início', with: notice.start_date.strftime('%Y-%m-%d'))
    expect(page).to have_field('Data final', with: notice.end_date.strftime('%Y-%m-%d'))
  end

  it 'atualiza o edital com sucesso' do
    new_name = 'Novo nome do edital'
    new_start_date = '2025-01-01'
    new_end_date = '2025-12-31'

    fill_in 'Nome', with: new_name
    fill_in 'Data de início', with: new_start_date
    fill_in 'Data final', with: new_end_date
    click_button 'Salvar'

    notice.reload
    expect(notice.name).to eq(new_name)
    expect(notice.start_date.strftime('%Y-%m-%d')).to eq(new_start_date)
    expect(notice.end_date.strftime('%Y-%m-%d')).to eq(new_end_date)

    expect(page).to have_current_path(notice_path(notice))
    expect(page).to have_content('Edital atualizado com sucesso')
  end

  it 'não atualiza o edital com dados inválidos' do
    fill_in 'Nome', with: ''
    fill_in 'Data de início', with: ''
    fill_in 'Data final', with: ''
    click_button 'Salvar'

    expect(page).to have_content('Nome não pode ficar em branco')
    expect(page).to have_content('Data de início não pode ficar em branco')
    expect(page).to have_content('Data final não pode ficar em branco')
  end
end
