json.set! :states do
  json.array! @states do |state|
    json.extract! state, :id, :name, :sort, :board
  end
end
