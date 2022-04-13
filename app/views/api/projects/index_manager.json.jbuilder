json.set! :projects do
  json.array! @projects do |project|
    json.extract! project, :id, :name, :workspace_id, :created_at, :updated_at
    json.role 0
    json.join @projects_check_join[project.id]
    json.set! :boards do
      json.array! project.boards do |board|
        json.extract! board, :id, :name, :project_id, :created_at, :updated_at
        json.role 0
      end
    end
  end
end
