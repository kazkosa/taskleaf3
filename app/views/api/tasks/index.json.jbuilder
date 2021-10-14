json.set! :tasks do
  json.array! @tasks do |task|
    json.extract! task, :id, :title, :content, :is_done, :created_at, :updated_at
  end
end
