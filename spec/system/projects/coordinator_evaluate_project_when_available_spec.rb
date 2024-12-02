require 'rails_helper'

RSpec.describe 'Coordinator evaluating projects', type: :system do
  let(:user) { create(:user, :coordinator) }
  let(:coordinator) { create(:coordinator, user: user) }
  let!(:project) { create(:project, coordinator: coordinator, project_status: 'em_analise') }

  before do
    login_as user, scope: :user
  end

  it 'exibe o formulário de avaliação do projeto' do
    visit edit_coordinator_project_path(coordinator_id: EncryptionService.encrypt(coordinator.id), id: EncryptionService.encrypt(project.id))

    expect(page).to have_content("Editar Projeto Nº #{project.ric_number}")
    expect(page).to have_selector('textarea[name="project[annotation]"]', visible: true)
    expect(page).to have_button('Adicionar pendência')
    expect(page).to have_button('Aprovar')
    expect(page).to have_button('Interromper')
    expect(page).to have_link('Voltar')
  end

  it 'adiciona pendência ao projeto', js: true do
    visit edit_coordinator_project_path(coordinator_id: EncryptionService.encrypt(coordinator.id), id: EncryptionService.encrypt(project.id))

    fill_in 'project[annotation]', with: 'Projeto requer ajustes na documentação.'
    click_button 'Adicionar pendência'

    expect(page).to have_content('Projeto atualizado com sucesso')
    expect(project.reload.project_status).to eq('pendente')
  end

  it 'aprova o projeto', js: true do
    visit edit_coordinator_project_path(coordinator_id: EncryptionService.encrypt(coordinator.id), id: EncryptionService.encrypt(project.id))

    fill_in 'project[annotation]', with: 'Projeto aprovado após revisão.'
    click_button 'Aprovar'

    expect(page).to have_content('Projeto atualizado com sucesso')
    expect(project.reload.project_status).to eq('aprovado')
  end

  it 'interrompe o projeto', js: true do
    visit edit_coordinator_project_path(coordinator_id: EncryptionService.encrypt(coordinator.id), id: EncryptionService.encrypt(project.id))

    fill_in 'project[annotation]', with: 'Projeto interrompido devido a inconsistências.'
    click_button 'Interromper'

    expect(page).to have_content('Projeto atualizado com sucesso')
    expect(project.reload.project_status).to eq('interrompido')
  end

  it 'exibe erros ao salvar sem preencher a anotação', js: true do
    visit edit_coordinator_project_path(coordinator_id: EncryptionService.encrypt(coordinator.id), id: EncryptionService.encrypt(project.id))

    fill_in 'project[annotation]', with: ''
    click_button 'Adicionar pendência'

    expect(page).to have_content('Anotação é obrigatório ao atualizar o projeto.')
    expect(project.reload.project_status).to eq('em_analise')
  end
end
