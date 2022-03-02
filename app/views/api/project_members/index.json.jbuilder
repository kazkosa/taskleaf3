json.set! :project_members do
  json.array! @members do |member|
    json.extract! member, :id, :user_id, :role, :role_before_type_cast
    json.extract! member.user, :name, :email
  end
end
