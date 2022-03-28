json.set! :workspaces do
  json.array! @workspaces do |workspace|
    json.extract! workspace, :id, :name, :created_at, :updated_at, :role, :projects
  end
end
