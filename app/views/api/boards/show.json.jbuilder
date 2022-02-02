json.set! :board do
  json.extract! @board, :id, :name, :description, :owner, :created_at, :updated_at
end
