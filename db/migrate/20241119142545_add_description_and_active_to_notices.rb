class AddDescriptionAndActiveToNotices < ActiveRecord::Migration[7.1]
  def change
    add_column :notices, :description, :text
    add_column :notices, :active, :boolean, default: true, null: false
  end
end
