class AddCategoryToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :category, :string
  end
end
