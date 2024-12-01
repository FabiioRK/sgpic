require 'rails_helper'

RSpec.describe 'Researcher creating a project', type: :system do
  let!(:user) { create(:user, :researcher) }
  let!(:researcher) { create(:researcher, user: user) }
  let!(:notices) do
    [
      create(:notice, name: "Edital de Teste 1", user: create(:user, :supervisor)),
      create(:notice, name: "Edital de Teste 2", user: create(:user, :supervisor)),
      create(:notice, name: "Edital de Teste 3", user: create(:user, :supervisor))
    ]
  end
  let!(:coordinators) do
    [
      create(:coordinator, name: "Coordenador Teste 1", user: create(:user, :coordinator, active: true)),
      create(:coordinator, name: "Coordenador Teste 2", user: create(:user, :coordinator, active: true))
    ]
  end

  before do
    login_as user
    visit new_researcher_project_path(researcher)
  end

  describe 'Formulário de criação de projeto' do
    context 'com dados válidos' do
      it 'cria um projeto com sucesso' do
        select 'Edital de Teste 1', from: 'project_notice_id'
        select 'Coordenador Teste 1', from: 'project_coordinator_id'
        select 'PIBIC', from: 'project_project_type'
        fill_in 'project_institution', with: 'Universidade Teste'
        fill_in 'project_course', with: 'Ciência da Computação'
        fill_in 'project_study_area', with: 'Inteligência Artificial'
        fill_in 'project_project_title', with: 'Projeto de Teste'
        fill_in 'project_research_line', with: 'Machine Learning'
        fill_in 'project_ods', with: 'Educação de Qualidade'
        fill_in 'project_key_words', with: 'IA, aprendizado de máquina'
        fill_in 'project_project_summary', with: 'Resumo detalhado do projeto'

        fill_in 'project_student_attributes_name', with: 'Estudante Teste'
        fill_in 'project_student_attributes_social_security_number', with: '123.456.789-00'
        fill_in 'project_student_attributes_identity_card_number', with: '123456789'
        fill_in 'project_student_attributes_birth_date', with: '2000-01-01'
        fill_in 'project_student_attributes_phone_number', with: '(11) 98765-4321'
        fill_in 'project_student_attributes_email', with: 'estudante@teste.com'
        fill_in 'project_student_attributes_academic_field', with: 'Computação'
        fill_in 'project_student_attributes_course', with: 'Ciência da Computação'
        fill_in 'project_student_attributes_semester', with: '5'
        check 'project_student_attributes_is_regular_student'

        fill_in 'project_student_attributes_address_attributes_postal_code', with: '12345-678'
        fill_in 'project_student_attributes_address_attributes_street', with: 'Rua Teste'
        fill_in 'project_student_attributes_address_attributes_district', with: 'Bairro Teste'
        fill_in 'project_student_attributes_address_attributes_city', with: 'Cidade Teste'
        fill_in 'project_student_attributes_address_attributes_state', with: 'Estado Teste'

        click_button 'Cadastrar Projeto'

        expect(page).to have_content('Projeto cadastrado com sucesso')
        expect(Project.count).to eq(1)
        project = Project.last
        expect(project.researcher).to eq(researcher)
        expect(project.student.name).to eq('Estudante Teste')
      end
    end

    context 'com dados inválidos' do
      it 'não cria um projeto sem preencher campos obrigatórios' do
        click_button 'Cadastrar Projeto'

        expect(page).to have_content('Não foi possível salvar projeto:')
        expect(page).to have_content('Edital é obrigatório(a)')
        expect(page).to have_content('Coordenador é obrigatório(a)')
        expect(page).to have_content('Instituição não pode ficar em branco')
        expect(page).to have_content('Curso não pode ficar em branco')
        expect(page).to have_content('Área de estudo não pode ficar em branco')
        expect(page).to have_content('Título do projeto não pode ficar em branco')
        expect(page).to have_content('Linha de pesquisa não pode ficar em branco')
        expect(page).to have_content('ODS não pode ficar em branco')
        expect(page).to have_content('Resumo do projeto não pode ficar em branco')
        expect(Project.count).to eq(0)
      end

      it 'não cria um projeto com dados do estudante incompletos' do
        fill_in 'project_student_attributes_name', with: ''
        fill_in 'project_student_attributes_social_security_number', with: ''
        fill_in 'project_student_attributes_email', with: ''
        click_button 'Cadastrar Projeto'

        expect(page).to have_content('CPF não pode ficar em branco')
        expect(page).to have_content('E-mail não pode ficar em branco')
        expect(page).to have_content('Nome não pode ficar em branco')
        expect(Project.count).to eq(0)
      end

      it 'não cria um projeto com dados de endereço incompletos' do
        fill_in 'project_student_attributes_address_attributes_postal_code', with: ''
        fill_in 'project_student_attributes_address_attributes_city', with: ''
        click_button 'Cadastrar Projeto'

        expect(page).to have_content('CEP não pode ficar em branco')
        expect(page).to have_content('Cidade não pode ficar em branco')
        expect(page).to have_content('CEP deve estar no formato XXXXX-XXX')
        expect(Project.count).to eq(0)
      end
    end

    context 'validação de anexos' do
      it 'não permite anexar mais de 5 arquivos' do
        attach_file 'project_attachments', [
          Rails.root.join('spec/fixtures/files/test1.pdf'),
          Rails.root.join('spec/fixtures/files/test2.pdf'),
          Rails.root.join('spec/fixtures/files/test3.pdf'),
          Rails.root.join('spec/fixtures/files/test4.pdf'),
          Rails.root.join('spec/fixtures/files/test5.pdf'),
          Rails.root.join('spec/fixtures/files/test6.pdf')
        ]

        click_button 'Cadastrar Projeto'

        expect(page).to have_content('Você pode anexar no máximo 5 arquivos por vez.')
        expect(Project.count).to eq(0)
      end

      it 'não permite arquivos maiores que 10MB' do
        attach_file 'project_attachments', Rails.root.join('spec/fixtures/files/large_file.pdf')

        click_button 'Cadastrar Projeto'

        expect(page).to have_content("O arquivo 'large_file.pdf' deve ter no máximo 10MB.")
        expect(Project.count).to eq(0)
      end

      it 'não permite arquivos com extensões inválidas' do
        attach_file 'project_attachments', Rails.root.join('spec/fixtures/files/invalid_file.txt')

        click_button 'Cadastrar Projeto'

        expect(page).to have_content("Formato do arquivo 'invalid_file.txt' não permitido. Apenas PDF, DOCX, ZIP, PNG e JPEG são aceitos.")
        expect(Project.count).to eq(0)
      end
    end
  end
end
