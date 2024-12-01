require 'rails_helper'

RSpec.describe 'Researcher solving pending issues', type: :system do
  let(:user) { create(:user, :researcher) }
  let(:researcher) { create(:researcher, user: user) }
  let!(:project) { create(:project, researcher: researcher, project_status: 'pendente') }

  before do
    login_as user, scope: :user
  end

  it 'exibe o formulário de pendências' do
    visit edit_researcher_project_path(researcher, project)

    expect(page).to have_content("Editar Projeto Nº #{project.ric_number}")
    expect(page).to have_selector('textarea[name="project[annotation]"]', visible: true)
    expect(page).to have_button('Atualizar projeto')
    expect(page).to have_link('Voltar')
  end

  it 'resolve pendências e altera o status para "em análise"', js: true do
    visit edit_researcher_project_path(researcher, project)

    fill_in 'project[annotation]', with: 'Resolvendo as pendências do projeto.'
    attach_file 'project[attachments][]', Rails.root.join('spec/fixtures/files/test1.pdf')
    click_button 'Atualizar projeto'

    expect(page).to have_current_path(researcher_project_path(researcher, project))
    expect(page).to have_content('Projeto atualizado com sucesso')
    expect(project.reload.project_status).to eq('em_analise')
  end


  it 'exibe erros ao salvar sem resolver pendências corretamente' do
    visit edit_researcher_project_path(researcher, project)

    fill_in 'project[annotation]', with: ''
    click_button 'Atualizar projeto'

    expect(page).to have_content('Anotação é obrigatório ao atualizar o projeto.')
    expect(project.reload.project_status).to eq('pendente')
  end
end
