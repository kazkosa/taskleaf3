json.set! :boards do
  json.array! @boards do |board|
    json.extract! board, :id, :name, :project_id,  :role, :role_before_type_cast
  end
end