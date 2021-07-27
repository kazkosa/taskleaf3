class CreateManagers < ActiveRecord::Migration[6.0]
  def change
    create_table :managers do |t|
      t.string :login_id
      t.string :password_digest
      t.boolean :admin
      t.timestamps
    end
  end
end
