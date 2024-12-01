require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'validações' do
    it 'é válido com atributos válidos' do
      student = build(:student,
                      name: 'Aluno Teste',
                      social_security_number: '123.456.789-00',
                      identity_card_number: '123456789',
                      semester: '1º',
                      email: 'student@example.com',
                      phone_number: '(11) 98765-4321',
                      birth_date: Date.today - 20.years,
                      project: create(:project))
      expect(student).to be_valid
    end

    it 'não é válido sem um número de CPF' do
      student = build(:student, social_security_number: nil)
      expect(student).to_not be_valid
      expect(student.errors[:social_security_number]).to include("não pode ficar em branco")
    end

    it 'não é válido com um CPF em formato inválido' do
      student = build(:student, social_security_number: '12345678900')
      expect(student).to_not be_valid
      expect(student.errors[:social_security_number]).to include("deve estar no formato XXX.XXX.XXX-XX")
    end

    it 'não é válido sem um número de RG' do
      student = build(:student, identity_card_number: nil)
      expect(student).to_not be_valid
      expect(student.errors[:identity_card_number]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um semestre' do
      student = build(:student, semester: nil)
      expect(student).to_not be_valid
      expect(student.errors[:semester]).to include("não pode ficar em branco")
    end

    it 'não é válido sem um email' do
      student = build(:student, email: nil)
      expect(student).to_not be_valid
      expect(student.errors[:email]).to include("não pode ficar em branco")
    end

    it 'não é válido com um email em formato inválido' do
      student = build(:student, email: 'invalid-email')
      expect(student).to_not be_valid
      expect(student.errors[:email]).to include("inválido")
    end

    it 'não é válido sem um número de telefone' do
      student = build(:student, phone_number: nil)
      expect(student).to_not be_valid
      expect(student.errors[:phone_number]).to include("não pode ficar em branco")
    end

    it 'não é válido com um número de telefone em formato inválido' do
      student = build(:student, phone_number: '12345-6789')
      expect(student).to_not be_valid
      expect(student.errors[:phone_number]).to include("deve estar no formato (XX) XXXXX-XXXX")
    end

    it 'não é válido com uma data de nascimento no futuro' do
      student = build(:student, birth_date: Date.today + 1.day)
      expect(student).to_not be_valid
      expect(student.errors[:base]).to include("data inválida")
    end
  end

  describe 'associações' do
    it { should belong_to(:project) }
    it { should have_one(:address) }
  end

  describe 'atributos aninhados' do
    it { should accept_nested_attributes_for(:address) }
  end
end
