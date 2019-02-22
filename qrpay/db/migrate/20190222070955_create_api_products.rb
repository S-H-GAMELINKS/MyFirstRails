class CreateApiProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :api_products do |t|
      t.string :name
      t.text :content
      t.integer :price

      t.timestamps
    end
  end
end
