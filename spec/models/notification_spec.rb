require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'validações' do
    it 'é válido com atributos válidos' do
      notification = build(:notification, user: create(:user, :supervisor), project: create(:project))
      expect(notification).to be_valid
    end

    it 'não é válido sem um usuário associado' do
      notification = build(:notification, user: nil, project: create(:project))
      expect(notification).to_not be_valid
      expect(notification.errors[:user]).to include("é obrigatório(a)")
    end

    it 'não é válido sem um projeto associado' do
      notification = build(:notification, user: create(:user, :supervisor), project: nil)
      expect(notification).to_not be_valid
      expect(notification.errors[:project]).to include("é obrigatório(a)")
    end
  end

  describe 'associações' do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
  end

  describe 'scopes' do
    let!(:unread_notification) { create(:notification, read: false, user: create(:user, :supervisor), project: create(:project)) }
    let!(:read_notification) { create(:notification, read: true, user: create(:user, :supervisor), project: create(:project)) }

    it 'retorna apenas notificações não lidas com o escopo unread' do
      expect(Notification.unread).to include(unread_notification)
      expect(Notification.unread).to_not include(read_notification)
    end

    it 'retorna apenas notificações lidas com o escopo read' do
      expect(Notification.read).to include(read_notification)
      expect(Notification.read).to_not include(unread_notification)
    end
  end

  describe '#mark_as_read!' do
    it 'marca uma notificação como lida' do
      notification = create(:notification, read: false, user: create(:user, :supervisor), project: create(:project))
      notification.mark_as_read!
      expect(notification.read).to be true
    end
  end

  describe 'callbacks' do
    it 'envia uma notificação por email após criar' do
      user = create(:user, :supervisor, email: 'test@example.com', active: true)
      project = create(:project)

      notification = build(:notification, user: user, project: project)
      expect(NotificationMailer).to receive(:notify_user).with(notification).and_call_original
      notification.save!
    end

    it 'não envia email se o usuário estiver inativo' do
      user = create(:user, :supervisor, email: 'test@example.com', active: false)
      project = create(:project)

      expect(NotificationMailer).to_not receive(:notify_user)
      create(:notification, user: user, project: project)
    end

    it 'não envia email se o usuário não tiver email' do
      user = create(:user, :supervisor, email: 'valid_email@example.com', active: true)
      project = create(:project)

      allow(user).to receive(:email).and_return(nil)

      expect(NotificationMailer).to_not receive(:notify_user)
      create(:notification, user: user, project: project)
    end
  end
end
