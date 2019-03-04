class CreateTalks < ActiveRecord::Migration[5.2]
  def change
    create_table :talks do |t|
      t.string :content
      t.references :room, foreign_key: true

      t.timestamps
    end
  end
end
