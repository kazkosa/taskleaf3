class AddIndexToUsersEmail < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :email, :string, limit: 191
    add_index :users, :email, unique: true
  end
end
