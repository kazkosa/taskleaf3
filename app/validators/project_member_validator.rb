class ProjectMemberValidator < ActiveModel::Validator
  def validate(record)
    if !record.project_members || record.project_members.empty?
      record.errors.add(:user_ids, :no_members, message: "No member in this project")
      return false
    else
      i = 0
      exclude_member = []
      workspace = record.workspace_id &&  Workspace.find(record.workspace_id)
      check_parent_member_flg = !!(workspace && !workspace.workspace_members.empty?)
      record.project_members.each do |member|
        i += 1 if member.role_before_type_cast == 0

        if check_parent_member_flg
          result = false
          result = workspace.workspace_members.find do |ws_member|
            ws_member.user_id == member.user_id
          end
          exclude_member.push(member.user.email) unless result
        end
      end

      if i == 0
        record.errors.add(:user_ids, :no_members, message: "No owner in this project")
      elsif i > 1
        record.errors.add(:user_ids, :no_members, message: "Duplicate owner in this project")
      elsif !exclude_member.empty?
        record.errors.add(:user_ids, :no_members, message: "(#{exclude_member.join(', ')}) cannot be set as a member because they are not members of workspace")
      else
        return true
      end
    end
  end
end