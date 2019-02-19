class AddAutherToNovel < ActiveRecord::Migration[5.2]
  def change
    add_column :novels, :auther, :string
  end
end
