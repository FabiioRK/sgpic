class ChangeFeedbackDateToDatetimeInProjects < ActiveRecord::Migration[7.1]
  def change
    change_column :projects, :feedback_date, :datetime
  end
end
