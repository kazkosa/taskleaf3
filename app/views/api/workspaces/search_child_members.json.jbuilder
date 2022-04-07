json.set! :projects do
  json.array! @projects do |project|
    json.extract! project, :id, :name, :workspace_id, :role, :role_before_type_cast
  end
end
json.set! :boards do
  json.array! @boards do |board|
    json.extract! board, :id, :name, :project_id,  :role, :role_before_type_cast
  end
end