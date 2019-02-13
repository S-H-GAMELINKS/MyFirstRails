class AddUseridToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_reference :questions, :user, foreign_key: true
  end
end
