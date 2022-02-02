class CreateWorkspaces < ActiveRecord::Migration[6.0]
  def change
    create_table :workspaces do |t|
      t.string :name
      t.references :owner, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
