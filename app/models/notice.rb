class Notice < ApplicationRecord
  belongs_to :user, foreign_key: :created_by, optional: false
  has_many :notice_histories, dependent: :destroy
  has_many :projects

  before_save :deactivate_if_expired
  validates :name, :start_date, :end_date, :description, :created_by, presence: true
  validates :name, length: { maximum: 255 }
  validate :valid_date

  def self.deactivate_expired
    where(active: true).where("end_date < ?", Date.today).update_all(active: false)
  end

  private

  def deactivate_if_expired
    self.active = false if end_date.present? && end_date < Date.today
  end

  def valid_date
    if start_date && end_date
      if start_date > end_date
        errors.add(:base, "A data de início não pode ser maior que a data final.")
      end

      if active_was == false && active == true
        if end_date < Date.today
          errors.add(:base, "Não é possível reativar um edital cuja data final já passou.")
        end
      elsif active_was == false && active == false || new_record?
        if start_date < Date.today
          errors.add(:base, "A data de início deve ser futura.")
        end
      end
    end
  end

end
