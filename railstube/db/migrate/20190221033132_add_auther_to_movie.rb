class AddAutherToMovie < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :auther, :string
  end
end
