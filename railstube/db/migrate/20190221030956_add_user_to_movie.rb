class AddUserToMovie < ActiveRecord::Migration[5.2]
  def change
    add_reference :movies, :user, foreign_key: true
  end
end
