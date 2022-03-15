class WorkspaceMemberValidator < ActiveModel::Validator
  def validate(record)
    if !record.workspace_members || record.workspace_members.empty?
      record.errors.add(:user_ids, :no_members, message: "No member in this workspace")
      return false
    else
      i = 0
      record.workspace_members.each do |member|
        i += 1 if member.role_before_type_cast == 0
      end
      if i == 0
        record.errors.add(:user_ids, :no_members, message: "No owner in this workspace")
      elsif i > 1
        record.errors.add(:user_ids, :no_members, message: "Duplicate owner in this workspace")
      else
        return true
      end
    end
  end
end