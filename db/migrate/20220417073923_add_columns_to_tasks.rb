class AddColumnsToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :user, foreign_key: true,  null: true
    add_reference :tasks, :state, foreign_key: true,  null: true
    add_reference :tasks, :board, foreign_key: true,  null: false
    add_column :tasks, :sort, :integer, default: 0, null: true
    add_column :tasks, :start_date, :date,  null: true
    add_column :tasks, :end_date, :date,  null: true
    add_column :tasks, :scheduled_start_date, :date,  null: true
    add_column :tasks, :scheduled_end_date, :date,  null: true
    add_column :tasks, :archive_flg, :boolean, default: false, null: true
  end
end
