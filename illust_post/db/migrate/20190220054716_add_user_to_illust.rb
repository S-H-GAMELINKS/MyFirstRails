class AddUserToIllust < ActiveRecord::Migration[5.2]
  def change
    add_reference :illusts, :user, foreign_key: true
  end
end
