json.set! :project do
  json.extract! @project, :id, :name, :description, :created_at, :updated_at, :role, :workspace_id
  json.join @projects_check_join
  json.set! :boards do
    json.array! @boards do |board|
      if board.project_id == @project.id
        if @pj_owner_flg
          json.extract! board, :id, :name, :description, :project, :created_at, :updated_at
          json.role 0
        else
          json.extract! board, :id, :name, :description, :project, :created_at, :updated_at, :role
        end
      end
    end
  end
end
