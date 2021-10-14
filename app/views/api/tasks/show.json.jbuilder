json.set! :task do
  json.extract! @task, :id, :title, :content, :is_done, :created_at, :updated_at
end
