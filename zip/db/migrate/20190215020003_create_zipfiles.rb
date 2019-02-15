class CreateZipfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :zipfiles do |t|

      t.timestamps
    end
  end
end
