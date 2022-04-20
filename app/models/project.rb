class Project < ApplicationRecord
  include ActiveModel::Validations
  validate :instance_validations, on: :create
  belongs_to :workspace, optional: true
  has_many :boards, foreign_key: :project_id, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members

  validates :name, presence: true, length: {maximum: 30}
  # validates :description, presence: true

  def build_member
    members = []
    ProjectMember.roles.keys.each do |role|
      temp_members = self.project_members.select { |member| member.role == role }
      members.concat(temp_members)
    end
    return members
  end

  def check_member(workspace_id, member_ids, member_roles)
    if !self.project_members || self.project_members.empty? || member_ids.empty?
      self.errors.add(:user_ids, :no_owner, message: "No member in this project")
      return false
    else
      i = 0
      member_roles.each do |member_role|
        i += 1 if member_role.to_i == 0
      end

      exclude_member = []
      workspace = !workspace_id.blank? && Workspace.find(workspace_id)

      # This project members must be the workspace members
      if workspace && !workspace.workspace_members.empty?
        member_ids.each do |target_member_id|
          result = false
          result = workspace.workspace_members.find do |member|
            member.user_id == target_member_id.to_i
          end
          exclude_member.push(User.find(target_member_id.to_i).email) unless result
        end
      end

      if i == 0
        self.errors.add(:user_ids, :no_members, message: "No owner in this project")
        return false
      elsif i > 1
        self.errors.add(:user_ids, :no_members, message: "Duplicate owner in this project")
        return false
      elsif !exclude_member.empty?
        self.errors.add(:user_ids, :no_members, message: "(#{exclude_member.join(', ')}) cannot be set as a member because they are not members of workspace")
        return false
      else
        return true
      end
    end
  end

  def instance_validations
    validates_with ::ProjectMemberValidator
  end

  def get_board_owners
    board_owners = []
    self.boards.each do |board|
      board_owners[board.id] = board.board_members.find { |member| member.role == 'owner' }.user
    end
    return board_owners
  end

  def member_is_board_owner?(members)
    board_owners = self.get_board_owners
    boards = self.boards
    result = []
    if !members.empty?
      members.each do |member|
        if board_owners.empty?
          result[member.user_id] = false
        else
          result[member.user_id] = !board_owners.find { |owner| !owner.nil? && owner.id == member.user_id }.nil?
        end
      end
    end
    return result
  end

  def diff_member (new_ids)
    current_ids = self.users.map { |user| user.id }
    return current_ids - new_ids.map(&:to_i)
  end

  def delete_child (target_delete_members)
    result = true
    if !target_delete_members.empty?
      self.boards.each do |board|
        target_delete_members.each do |target_delete_member|
          tasks = Task.where(board_id: board.id, user_id: target_delete_member)
          tasks.each do |task|
            task.user_id = nil
            result = false unless task.save
          end
          bd_member = BoardMember.find_by(board_id: board.id, user_id: target_delete_member)
          if bd_member && !bd_member.destroy
            result = false
          end
        end
      end
    end
    return result
  end

  def update_members(new_ids, roles, sendmail_user_ids = [], from_user = nil)
    result = true
    self.project_members.each do |member|
      index = new_ids.index(member.user_id)
      member.role = (roles[index]).to_i
      if member.save
        if !sendmail_user_ids.empty? && from_user
          sendmail_user_id = sendmail_user_ids.find { |n| n == member.user_id}
          sendmail_user = sendmail_user_id && User.find(sendmail_user_id)
          from_user.send_announcement_email_of_join_the_project_mail(sendmail_user, self) if sendmail_user
        end
      else
        result = false
      end
    end
    return result
  end
end
