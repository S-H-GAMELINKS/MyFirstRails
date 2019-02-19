class AddUserToNovel < ActiveRecord::Migration[5.2]
  def change
    add_reference :novels, :user, foreign_key: true
  end
end
