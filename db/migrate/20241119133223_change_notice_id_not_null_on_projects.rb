class ChangeNoticeIdNotNullOnProjects < ActiveRecord::Migration[7.1]
  def change
    change_column_null :projects, :notice_id, false
  end
end
