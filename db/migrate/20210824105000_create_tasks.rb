class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.string :content
      t.boolean :is_done, default: false, null: false

      t.timestamps
    end
  end
end
