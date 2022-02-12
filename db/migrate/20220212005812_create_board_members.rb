class CreateBoardMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :board_members do |t|
      t.references :board, foreign_keyt: true
      t.references :user, foreign_keyt: true
      t.integer :role, default: 0, null: true
      t.timestamps
    end
  end
end
