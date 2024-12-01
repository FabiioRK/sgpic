class AddUniqueIndexToProjectsRicNumber < ActiveRecord::Migration[7.1]
  def change
    add_index :projects, :ric_number, unique: true
  end
end
