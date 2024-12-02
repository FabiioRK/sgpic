require 'rails_helper'

RSpec.describe 'Researcher viewing notices', type: :system do
  let!(:user) { create(:user, :researcher) }
  let!(:researcher) { create(:researcher, user: user) }
  let!(:active_notices) { create_list(:notice, 5, active: true, user: create(:user, :supervisor)) }
  let!(:inactive_notices) { create_list(:notice, 3, active: false, user: create(:user, :supervisor)) }

  before do
    login_as user, scope: :user
    visit notices_path
  end

  describe 'Visualização da lista de editais' do
    it 'exibe todos os editais, tanto ativos quanto inativos' do
      next_page = 2
      (active_notices + inactive_notices).each do |notice|
        unless page.has_content?(notice.name)
          click_link "#{next_page}" if page.has_link?("#{next_page}")
          next_page += 1
        end
        expect(page).to have_content(notice.name)
      end
    end

    it 'não permite editar, excluir ou alterar status de um edital' do
      active_notices.each do |notice|
        within(:xpath, "//li[contains(@class, 'list-group-item') and .//h5[text()='#{notice.name}']]") do
          expect(page).not_to have_link('Editar')
          expect(page).not_to have_link('Excluir')
          expect(page).not_to have_link('Desativar')
          expect(page).not_to have_link('Ativar')
        end
      end
    end
  end

  describe 'Detalhes do edital' do
    it 'exibe a página de detalhes de um edital' do
      notice = active_notices.first

      within(:xpath, "//li[contains(@class, 'list-group-item') and .//h5[text()='#{notice.name}']]") do
        click_link 'Ver Detalhes'
      end

      expect(page).to have_content("Detalhes do Edital: #{notice.name}")
      expect(page).to have_content(notice.description)
      expect(page).to have_content(notice.start_date.strftime('%d/%m/%Y'))
      expect(page).to have_content(notice.end_date.strftime('%d/%m/%Y'))
      expect(page).to have_content('Ativo')
    end

    it 'não exibe opções de edição, exclusão ou alteração de status no detalhe do edital' do
      notice = active_notices.first

      visit notice_path(id: EncryptionService.encrypt(notice.id))

      expect(page).not_to have_link('Editar')
      expect(page).not_to have_link('Excluir')
      expect(page).not_to have_link('Desativar')
      expect(page).not_to have_link('Ativar')
    end
  end
end
