json.set! :board do
  json.extract! @board, :id, :name, :description, :created_at, :updated_at
end
json.set! :project do
  json.extract! @board.project, :id, :name, :description, :created_at, :updated_at, :workspace_id
end