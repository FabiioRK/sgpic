require 'rails_helper'

RSpec.describe 'Researcher visualizando notificações', type: :system do
  let!(:user) { create(:user, :researcher) }
  let!(:researcher) { create(:researcher, user: user) }
  let!(:unread_notifications) { create_list(:notification, 3, user: user, read: false, message: 'Nova notificação') }
  let!(:read_notifications) { create_list(:notification, 2, user: user, read: true, message: 'Notificação lida') }

  before do
    login_as user, scope: :user
  end

  describe 'Acessando a página de notificações' do
    it 'exibe a lista de notificações' do
      visit notifications_path

      expect(page).to have_content('Minhas Notificações')

      unread_notifications.each do |notification|
        expect(page).to have_content(notification.message)
        expect(page).to have_selector('.unread', text: notification.message)
      end

      read_notifications.each do |notification|
        expect(page).to have_content(notification.message)
        expect(page).to have_selector('.read', text: notification.message)
      end
    end

    it 'exibe o botão "Marcar todas como lidas" se houver notificações não lidas' do
      visit notifications_path

      expect(page).to have_button('Marcar todas como lidas')
    end
  end

  describe 'Marcando notificações como lidas' do
    it 'permite marcar uma notificação individual como lida' do
      visit notifications_path

      notification = unread_notifications.first
      within("li.unread", match: :first) do
        expect(page).to have_content(notification.message)
        click_button 'Marcar como lida'
      end

      expect(page).to have_content('Notificação marcada como lida.')
    end

    it 'permite marcar todas as notificações como lidas' do
      visit notifications_path

      click_button 'Marcar todas como lidas'

      expect(page).to have_content('Todas as notificações foram marcadas como lidas.')
      unread_notifications.each do |notification|
        expect(notification.reload.read).to be true
      end
    end
  end

  describe 'Paginação' do
    it 'mostra a paginação quando há muitas notificações' do
      create_list(:notification, 10, user: user, read: false, message: 'Notificação extra')

      visit notifications_path

      expect(page).to have_selector('.pagination')
    end
  end

  describe 'Quando não há notificações' do
    it 'exibe uma mensagem indicando a ausência de notificações' do
      user.notifications.destroy_all

      visit notifications_path

      expect(page).to have_content('Você não tem notificações no momento.')
      expect(page).to have_selector('.bi-bell-slash')
    end
  end
end
