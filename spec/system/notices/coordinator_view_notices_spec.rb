require 'rails_helper'

RSpec.describe 'Coordinator viewing notices', type: :system do
  let!(:user) { create(:user, :coordinator) }
  let!(:coordinator) { create(:coordinator, user: user) }
  let!(:active_notices) { create_list(:notice, 10, active: true, user: create(:user, :supervisor)) }
  let!(:inactive_notices) { create_list(:notice, 3, active: false, user: create(:user, :supervisor)) }

  before do
    login_as user, scope: :user
    visit notices_path
  end

  describe 'Visualização da lista de editais' do
    it 'exibe todos os editais inicialmente' do
      next_page = 2
      (active_notices + inactive_notices).each do |notice|
        unless page.has_content?(notice.name)
          click_link "#{next_page}" if page.has_link?("#{next_page}")
          next_page += 1
        end
        expect(page).to have_content(notice.name)
      end
    end

    it 'filtra editais ativos corretamente' do
      click_link 'Ativo (10)'

      next_page = 2
      active_notices.each do |notice|
        unless page.has_content?(notice.name)
          click_link "#{next_page}" if page.has_link?("#{next_page}")
          next_page += 1
        end
        expect(page).to have_content(notice.name)
      end

      inactive_notices.each do |notice|
        expect(page).not_to have_content(notice.name)
      end
    end

    it 'filtra editais inativos corretamente' do
      click_link 'Inativo (3)'

      inactive_notices.each do |notice|
        expect(page).to have_content(notice.name)
      end

      active_notices.each do |notice|
        expect(page).not_to have_content(notice.name)
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
  end

  describe 'Paginação' do
    it 'exibe 5 editais por página' do
      create_list(:notice, 5, active: true, user: create(:user, :supervisor))

      visit notices_path

      first_page_notices = Notice.order(active: :desc, start_date: :desc).limit(5)
      first_page_notices.each do |notice|
        expect(page).to have_content(notice.name)
      end

      click_link '2'
      second_page_notices = Notice.order(active: :desc, start_date: :desc).offset(5).limit(5)
      second_page_notices.each do |notice|
        expect(page).to have_content(notice.name)
      end

      click_link '3'
      third_page_notices = Notice.order(active: :desc, start_date: :desc).offset(10).limit(5)
      third_page_notices.each do |notice|
        expect(page).to have_content(notice.name)
      end

      click_link '4'
      last_page_notices = Notice.order(active: :desc, start_date: :desc).offset(15).limit(5)
      last_page_notices.each do |notice|
        expect(page).to have_content(notice.name)
      end

      expect(last_page_notices.count).to eq(3)
    end

  end
end
