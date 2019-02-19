class AddAutherToComment < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :auther, :string
  end
end
