json.set! :boards do
  json.array! @boards do |board|
    json.extract! board, :id, :name, :project_id, :created_at, :updated_at, :role
  end
end
