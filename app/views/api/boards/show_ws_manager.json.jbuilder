json.set! :board do
  json.extract! @board, :id, :name, :description, :created_at, :updated_at, :project_id
  json.role 0
  json.join @board_check_join
  json.states @board.states.order("states.sort")
end
json.set! :project do
  json.extract! @project, :id, :name, :description, :created_at, :updated_at, :workspace_id
  json.role 0
end
json.set! :workspace do
  json.extract! @workspace, :id, :name, :role, :role_before_type_cast
end
