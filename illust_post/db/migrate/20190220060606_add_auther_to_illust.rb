class AddAutherToIllust < ActiveRecord::Migration[5.2]
  def change
    add_column :illusts, :auther, :string
  end
end
