class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.date :date
      t.integer :money
      t.string :category
      t.text :about
      t.boolean :income

      t.timestamps
    end
  end
end
