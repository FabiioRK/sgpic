require 'rails_helper'

RSpec.describe AnnotationHistory, type: :model do
  describe 'validações' do
    let(:coordinator) { create(:coordinator, user: create(:user, :coordinator)) }
    let(:researcher) { create(:researcher, user: create(:user, :researcher)) }
    let(:project) { create(:project, researcher: researcher, coordinator: coordinator) }

    it 'é válido com atributos válidos' do
      annotation_history = build(:annotation_history, project: project, user: coordinator.user)
      expect(annotation_history).to be_valid
    end

    it 'não é válido sem o usuário (created_by)' do
      annotation_history = build(:annotation_history, project: project, user: nil)
      expect(annotation_history).to_not be_valid
      expect(annotation_history.errors[:created_by]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um projeto associado' do
      annotation_history = build(:annotation_history, project: nil, user: coordinator.user)
      expect(annotation_history).to_not be_valid
      expect(annotation_history.errors[:project]).to include("é obrigatório(a)")
    end
  end

  describe 'associações' do
    it { should belong_to(:project) }
    it { should belong_to(:user).with_foreign_key('created_by') }
  end
end
