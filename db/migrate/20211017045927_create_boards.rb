class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|
      t.string :name, null: false
      t.text :description
      # t.references :owner, foreign_key: { to_table: :users }
      t.references :project, foreign_key: true
      t.timestamps
    end
  end
end
