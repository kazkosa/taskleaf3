json.set! :board do
  json.extract! @board, :id, :name, :description, :created_at, :updated_at
end
