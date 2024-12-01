require 'rails_helper'

RSpec.describe 'Researcher viewing projects', type: :system do
  let(:user) { create(:user, :researcher) }
  let(:researcher) { create(:researcher, user: user) }
  let(:other_user) { create(:user, :researcher) }
  let(:other_researcher) { create(:researcher, user: other_user) }
  let!(:own_projects) { create_list(:project, 5, researcher: researcher, project_status: 'aprovado') }
  let!(:other_projects) { create_list(:project, 3, researcher: other_researcher, project_status: 'pendente') }

  before do
    login_as user, scope: :user
  end

  it 've seus próprios projetos' do
    expect(user.role == 'researcher')

    visit researcher_projects_path(researcher)
    own_projects.each do |project|
      expect(page).to have_content(project.project_title)
      expect(page).to have_content(project.ric_number)
    end
  end

  it 'não vê projetos de outros pesquisadores' do
    visit researcher_projects_path(researcher)
    other_projects.each do |project|
      expect(page).not_to have_content(project.project_title)
      expect(page).not_to have_content(project.ric_number)
    end
  end

  it 'vê detalhes de um projeto' do
    project = own_projects.first
    visit researcher_projects_path(researcher)
    click_link 'Detalhes', href: researcher_project_path(researcher, project)

    expect(page).to have_content("Visualização do projeto Nº #{project.ric_number}")
    expect(page).to have_content(project.project_title)
    expect(page).to have_content(project.project_summary)
    expect(page).to have_content(project.student.name)
  end

  it 'filtra projetos por status' do
    visit researcher_projects_path(researcher)

    click_link 'Aprovado (5)'
    own_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end
    other_projects.each do |project|
      expect(page).not_to have_content(project.project_title)
    end
  end

  it 'vai para a segunda página e vê outros projetos' do
    create_list(:project, 24, researcher: researcher, project_status: 'em_analise') # Total de 29 projetos

    visit researcher_projects_path(researcher)

    first_page_projects = researcher.projects.order(project_status: :asc, created_at: :desc).limit(12)
    first_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end

    click_link '2'

    second_page_projects = researcher.projects.order(project_status: :asc, created_at: :desc).offset(12).limit(12)
    second_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end
  end

  it 'exibe o número correto de projetos na última página' do
    create_list(:project, 25, researcher: researcher, project_status: 'aprovado')

    visit researcher_projects_path(researcher)
    click_link '3'

    last_page_projects = researcher.projects.order(project_status: :asc, created_at: :desc).offset(24)
    last_page_projects.each do |project|
      expect(page).to have_content(project.project_title)
    end

    expect(last_page_projects.count).to eq(6)
  end

  it 'exibe mensagem quando não há projetos para o status selecionado' do
    visit researcher_projects_path(researcher, status: 'pendente')
    expect(page).to have_content('Nenhum projeto encontrado')
    expect(page).to have_content('Assim que projetos estiverem com o status pendente, eles aparecerão aqui.')
  end
end
