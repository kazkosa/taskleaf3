json.set! :project do
  json.extract! @project, :id, :name, :description, :owner, :created_at, :updated_at
end
json.set! :boards do
  json.array! @project.boards do |board|
    json.extract! board, :id, :name, :description, :owner, :project, :created_at, :updated_at
  end
end
