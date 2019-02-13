class AddCategoryToquestion < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :category, :string
  end
end
