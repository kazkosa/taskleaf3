class MemberValidator < ActiveModel::Validator
  def validate(record)
    if !record.project_members || record.project_members.empty?
      record.errors.add(:user_ids, :no_members, message: "No member in this project")
      return false
    else
      return true
    end
  end
end