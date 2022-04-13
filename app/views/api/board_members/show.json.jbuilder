json.set! :board_member do
  json.extract! @board_member, :id, :board_id, :user_id, :role_before_type_cast, :role
end
