json.set! :projects do
  json.array! @projects do |project|
    json.extract! project, :id, :name, :workspace_id, :created_at, :updated_at, :role, :role_before_type_cast
    json.set! :boards do
      json.array! @boards[project.id] do |board|
        if @pj_owner_flg
          json.extract! board, :id, :name, :project_id, :created_at, :updated_at
          json.role 0
        else
          json.extract! board, :id, :name, :project_id, :created_at, :updated_at, :role,  :role_before_type_cast
        end
      end
    end
  end
end
