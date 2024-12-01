FactoryBot.define do
  factory :project do
    project_type { :PIBIC }
    project_title { Faker::Lorem.sentence(word_count: 3) }
    institution { "Universidade de Teste" }
    course { "Ciência da Computação" }
    study_area { "Tecnologia" }
    research_line { "Inteligência Artificial" }
    ods { "Educação de Qualidade" }
    project_summary { "Resumo do projeto de teste." }
    key_words { "IA, tecnologia, educação" }
    researcher
    coordinator
    notice

    after(:create) do |project|
      create(:student, project: project)
    end
  end
end
