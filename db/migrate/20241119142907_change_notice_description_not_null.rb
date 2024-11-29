class ChangeNoticeDescriptionNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :notices, :description, false
  end
end
