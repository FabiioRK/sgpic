class ChangeIntegerToBigint < ActiveRecord::Migration[7.1]
  def change
    change_column :projects, :ric_number, :bigint
    change_column :annotation_histories, :project_id, :bigint
    change_column :students, :project_id, :bigint
  end
end
