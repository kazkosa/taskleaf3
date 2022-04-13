json.set! :project do
  json.extract! @project, :id, :name, :description, :workspace_id
  json.role 0
  json.join @projects_check_join
  json.set! :boards do
    json.array! @project.boards do |board|
      json.extract! board, :id, :name, :project_id, :created_at, :updated_at
      json.role 0
    end
  end
end
