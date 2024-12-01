require 'rails_helper'

RSpec.describe 'Coordinator viewing projects', type: :system do
  let(:user) { create(:user, :coordinator) }
  let(:coordinator) { create(:coordinator, user: user) }
  let(:other_user) { create(:user, :coordinator) }
  let(:other_coordinator) { create(:coordinator, user: other_user) }
  let!(:own_projects) { create_list(:project, 5, coordinator: coordinator, project_status: 'aprovado') }
  let!(:other_projects) { create_list(:project, 3, coordinator: other_coordinator, project_status: 'pendente') }

  before do
    login_as user, scope: :user
  end

  it 'vê seus próprios projetos' do
    expect(user.role).to eq('coordinator')

    visit coordinator_projects_path(coordinator)
    own_projects.each do |project|
      expect(page).to have_content(project.project_title)
      expect(page).to have_content(project.ric_number)
    end
  end

  it 'não vê projetos de outros coordenadores' do
    visit coordinator_projects_path(coordinator)
    other_projects.each do |project|
      expect(page).not_to have_content(project.project_title)
      expect(page).not_to have_content(project.ric_number)
    end
  end

  it 'vê detalhes de um projeto' do
    project = own_projects.first
    visit coordinator_projects_path(coordinator)
    click_link 'Detalhes', href: coordinator_project_path(coordinator, project)

    expect(page).to have_content("Visualização do projeto Nº #{project.ric_number}")
    expect(page).to have_content(project.project_title)
    expect(page).to have_content(project.project_summary)
    expect(page).to have_content(project.student.name)
  end

  it 'filtra projetos por status' do
    visit coordinator_projects_path(coordinator)

    click_link 'Aprovado (5)'
    own_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end
    other_projects.each do |project|
      expect(page).not_to have_content(project.project_title)
    end
  end

  it 'vai para a segunda página e vê outros projetos' do
    create_list(:project, 24, coordinator: coordinator, project_status: 'em_analise') # Total de 29 projetos

    visit coordinator_projects_path(coordinator)

    first_page_projects = coordinator.projects.order(project_status: :asc, created_at: :desc).limit(12)
    first_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end

    click_link '2'

    second_page_projects = coordinator.projects.order(project_status: :asc, created_at: :desc).offset(12).limit(12)
    second_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end
  end

  it 'exibe o número correto de projetos na última página' do
    create_list(:project, 25, coordinator: coordinator, project_status: 'aprovado')

    visit coordinator_projects_path(coordinator)
    click_link '3'

    last_page_projects = coordinator.projects.order(project_status: :asc, created_at: :desc).offset(24)
    last_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end

    expect(last_page_projects.count).to eq(6)
  end

  it 'exibe mensagem quando não há projetos para o status selecionado' do
    visit coordinator_projects_path(coordinator, status: 'pendente')
    expect(page).to have_content('Nenhum projeto encontrado')
    expect(page).to have_content('Assim que projetos estiverem com o status pendente, eles aparecerão aqui.')
  end
end
