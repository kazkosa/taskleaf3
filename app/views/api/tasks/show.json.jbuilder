json.set! :task do
  json.extract! @task, :id, :title, :content, :is_done, :start_date, :end_date, :scheduled_start_date, :scheduled_end_date, :board_id, :state_id, :user_id, :created_at, :updated_at, :state, :user
  json.project @task.board.project
end
