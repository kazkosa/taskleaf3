json.set! :workspaces do
  json.array! @workspaces do |workspace|
    json.extract! workspace, :id, :name, :created_at, :updated_at, :role

    # json.set! :projects do
    #   json.array! @projects[workspace.id] do |project|
    #     if project.workspace_id == workspace.id
    #       json.extract! project, :id, :name, :workspace_id, :created_at, :updated_at, :role
    #     end
    #   end
    # end



  end
end
