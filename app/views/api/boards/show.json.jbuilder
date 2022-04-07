json.set! :board do
  json.extract! @board, :id, :name, :description, :created_at, :updated_at, :project_id
end
json.set! :project do
  json.extract! @board.project, :id, :name, :description, :created_at, :updated_at, :workspace_id
end
if @workspace
  json.set! :workspace do
    json.extract! @workspace, :id, :name, :role, :role_before_type_cast
  end
end