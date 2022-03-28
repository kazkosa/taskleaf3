json.set! :project do
  json.extract! @project, :id, :name, :description, :created_at, :updated_at, :role, :workspace_id
end
json.set! :boards do
  json.array! @project.boards do |board|
    json.extract! board, :id, :name, :description, :project, :created_at, :updated_at, :role
  end
end
