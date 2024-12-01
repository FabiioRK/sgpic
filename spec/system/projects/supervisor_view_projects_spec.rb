require 'rails_helper'

RSpec.describe 'Supervisor viewing all projects', type: :system do
  let(:user) { create(:user, :supervisor) }
  let!(:projects) { create_list(:project, 5, project_status: 'em_analise') }
  let!(:approved_projects) { create_list(:project, 3, project_status: 'aprovado') }
  let!(:pending_projects) { create_list(:project, 2, project_status: 'pendente') }

  before do
    login_as user, scope: :user
  end

  it 'vê todos os projetos disponíveis' do
    visit supervisor_projects_path

    projects.each do |project|
      expect(page).to have_content(project.project_title)
      expect(page).to have_content(project.ric_number)
    end

    approved_projects.each do |project|
      expect(page).to have_content(project.project_title)
      expect(page).to have_content(project.ric_number)
    end

    pending_projects.each do |project|
      expect(page).to have_content(project.project_title)
      expect(page).to have_content(project.ric_number)
    end
  end

  it 'visualiza projetos de diferentes usuários' do
    researcher1 = create(:researcher)
    researcher2 = create(:researcher)
    coordinator = create(:coordinator)

    project_from_researcher1 = create(:project, researcher: researcher1, project_status: 'em_analise')
    project_from_researcher2 = create(:project, researcher: researcher2, project_status: 'pendente')
    project_from_coordinator = create(:project, coordinator: coordinator, project_status: 'aprovado')

    visit supervisor_projects_path

    expect(page).to have_content(project_from_researcher1.project_title)
    expect(page).to have_content(project_from_researcher1.ric_number)

    expect(page).to have_content(project_from_researcher2.project_title)
    expect(page).to have_content(project_from_researcher2.ric_number)

    expect(page).to have_content(project_from_coordinator.project_title)
    expect(page).to have_content(project_from_coordinator.ric_number)
  end


  it 'vê detalhes de um projeto' do
    project = projects.first
    visit supervisor_projects_path

    click_link 'Detalhes', href: supervisor_project_path(project)

    expect(page).to have_content("Visualização do projeto Nº #{project.ric_number}")
    expect(page).to have_content(project.project_title)
    expect(page).to have_content(project.project_summary)
    expect(page).to have_content(project.student.name)
  end

  it 'filtra projetos por status' do
    visit supervisor_projects_path

    click_link 'Em análise (5)'
    projects.each do |project|
      expect(page).to have_content(project.project_title)
    end

    approved_projects.each do |project|
      expect(page).not_to have_content(project.project_title)
    end

    pending_projects.each do |project|
      expect(page).not_to have_content(project.project_title)
    end
  end

  it 'vai para a segunda página e vê outros projetos' do
    create_list(:project, 20, project_status: 'em_analise')

    visit supervisor_projects_path

    first_page_projects = Project.order(project_status: :asc, created_at: :desc).limit(12)
    first_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end

    click_link '2'

    second_page_projects = Project.order(project_status: :asc, created_at: :desc).offset(12).limit(12)
    second_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end
  end

  it 'exibe o número correto de projetos na última página' do
    total_existing_projects = projects.count + approved_projects.count + pending_projects.count
    create_list(:project, 25, project_status: 'aprovado')

    total_projects = total_existing_projects + 25
    expect(Project.count).to eq(total_projects)

    visit supervisor_projects_path
    click_link '3'

    per_page = 12
    last_page_offset = ((total_projects - 1) / per_page) * per_page
    last_page_projects = Project.order(project_status: :asc, created_at: :desc).offset(last_page_offset).limit(per_page)

    last_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end

    expect(last_page_projects.count).to eq(total_projects % per_page)
  end


  it 'exibe mensagem quando não há projetos para o status selecionado' do
    visit supervisor_projects_path(status: 'interrompido')

    expect(page).to have_content('Nenhum projeto encontrado')
    expect(page).to have_content('Assim que projetos estiverem com o status interrompido, eles aparecerão aqui.')
  end
end
