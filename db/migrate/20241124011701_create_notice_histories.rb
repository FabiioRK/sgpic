class CreateNoticeHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :notice_histories do |t|
      t.references :notice, null: false, foreign_key: true
      t.integer :edited_by, null: false
      t.json :changes_made, null: false
      t.datetime :edited_at, null: false

      t.timestamps
    end
  end
end
