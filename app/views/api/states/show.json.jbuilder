if @state
  json.set! :state do
    json.extract! @state, :id, :name, :sort
  end
end