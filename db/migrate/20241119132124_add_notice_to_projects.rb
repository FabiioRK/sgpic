class AddNoticeToProjects < ActiveRecord::Migration[7.1]
  def change
    add_reference :projects, :notice, null: true, foreign_key: true
  end
end
