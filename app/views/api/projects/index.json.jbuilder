json.set! :projects do
  json.array! @projects do |project|
    json.extract! project, :id, :name, :workspace, :created_at, :updated_at

    json.set! :boards do
      json.array! project.boards do |board|
        json.extract! board, :id, :name, :project, :created_at, :updated_at
      end
    end

  end
end
