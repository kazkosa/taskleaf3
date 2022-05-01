json.set! :tasks do
  json.array! @tasks do |task|
    json.extract! task, :id, :title, :content, :is_done, :sort, :board_id, :state_id, :created_at, :updated_at
  end
end
