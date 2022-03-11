class CreateWorkspaceMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :workspace_members do |t|
      t.references :workspace, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :role, default: 0, null: true
      t.timestamps
    end
  end
end
