class AddScoreToComment < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :score, :integer
  end
end
