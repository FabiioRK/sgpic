class CreateAnnotationHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :annotation_histories do |t|
      t.text :annotation
      t.references :project, null: false, foreign_key: true
      t.integer :created_by

      t.timestamps
    end
  end
end
