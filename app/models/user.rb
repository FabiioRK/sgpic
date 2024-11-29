class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    supervisor: 0,
    coordinator: 1,
    researcher: 3
  }

  has_one :supervisor, dependent: :destroy
  has_one :coordinator, dependent: :destroy
  has_one :researcher, dependent: :destroy
  accepts_nested_attributes_for :coordinator
  accepts_nested_attributes_for :researcher
  has_many :notifications, dependent: :destroy

  after_create :create_supervisor

  def display_name
    coordinator&.name || researcher&.name || supervisor&.name
  end

  def supervisor?
    role == 'supervisor'
  end

  private
  def create_supervisor
    case role.to_sym
    when :supervisor
      create_supervisor!
    end
  end

end
