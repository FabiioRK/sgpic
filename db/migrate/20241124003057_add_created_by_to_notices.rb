class AddCreatedByToNotices < ActiveRecord::Migration[7.1]
  def change
    add_column :notices, :created_by, :integer
  end
end
