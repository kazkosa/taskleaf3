class BoardMemberValidator < ActiveModel::Validator
  def validate(record)
    if !record.board_members || record.board_members.empty?
      record.errors.add(:user_ids, :no_members, message: "No member in this board")
      return false
    else
      i = 0
      exclude_member = []
      project = record.project_id &&  Project.find(record.project_id)
      check_parent_member_flg = !!(project && !project.project_members.empty?)
      record.board_members.each do |member|
        i += 1 if member.role_before_type_cast == 0

        if check_parent_member_flg
          result = false
          result = project.project_members.find do |pj_member|
            pj_member.user_id == member.user_id
          end
          exclude_member.push(member.user.email) unless result
        end
      end

      if i == 0
        record.errors.add(:user_ids, :no_members, message: "No owner in this board")
      elsif i > 1
        record.errors.add(:user_ids, :no_members, message: "Duplicate owner in this board")
      elsif !exclude_member.empty?
        record.errors.add(:user_ids, :no_members, message: "(#{exclude_member.join(', ')}) cannot be set as a member because they are not members of project")
      else
        return true
      end
    end
  end
end