json.set! :states do
  json.array! @states do |state|
    json.extract! state, :id, :name, :sort, :board
    json.tasks state.tasks.order("tasks.sort")
  end
end
