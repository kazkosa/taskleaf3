json.set! :project_member do
  json.extract! @project_member, :id, :project_id, :user_id, :role_before_type_cast, :role
end
