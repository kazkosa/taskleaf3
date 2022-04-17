class CreateStates < ActiveRecord::Migration[6.0]
  def change
    create_table :states do |t|
      t.string :name, null: false
      t.integer :sort, default: 0, null: true
      t.references :board, foreign_key: true
      t.timestamps
    end
  end
end
