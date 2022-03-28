json.set! :workspace do
  json.extract! @workspace, :id, :name, :created_at, :updated_at, :role
end
json.set! :projects do
  json.array! @workspace.projects do |project|
    json.extract! project, :id, :name, :created_at, :updated_at, :role
  end
end
