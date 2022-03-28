json.set! :projects do
  json.array! @projects do |project|
    json.extract! project, :id, :name, :workspace_id, :created_at, :updated_at, :role, :boards, :workspace_id
  end
end
