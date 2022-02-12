class BoardMemberValidator < ActiveModel::Validator
  def validate(record)
    if !record.board_members || record.board_members.empty?
      record.errors.add(:user_ids, :no_members, message: "No member in this board")
      return false
    else
      return true
    end
  end
end