class Workspace < ApplicationRecord
  include ActiveModel::Validations
  validate :instance_validations, on: :create

  # belongs_to :owner, class_name: "User"
  has_many :projects, foreign_key: :workspace_id, dependent: :destroy
  has_many :workspace_members, dependent: :destroy
  has_many :users, through: :workspace_members
  
  validates :name, presence: true, length: {maximum: 30}

  def build_member
    members = []
    WorkspaceMember.roles.keys.each do |role|
      temp_members = self.workspace_members.select { |member| member.role == role }
      members.concat(temp_members)
    end
    return members
  end

  def check_member(member_ids, member_roles)
    if !self.workspace_members || self.workspace_members.empty? || member_ids.empty?
      self.errors.add(:user_ids, :no_owner, message: "No member in this workspace")
      return false
    else
      i = 0
      member_roles.each do |member_role|
        i += 1 if member_role.to_i == 0
      end

      if i == 0
        self.errors.add(:user_ids, :no_members, message: "No owner in this workspace")
        return false
      elsif i > 1
        self.errors.add(:user_ids, :no_members, message: "Duplicate owner in this workspace")
        return false
      else
        return true
      end
    end
  end
  def instance_validations
    validates_with ::WorkspaceMemberValidator
  end

  def get_project_owners
    project_owners = []
    self.projects.each do |project|
      project_owners[project.id] = project.project_members.find { |member| member.role == 'owner' }.user
    end
    return project_owners
  end

  def get_board_owners
    board_owners = []
    self.projects.each do |project|
      project.boards.each do |board|
        board_owners[board.id] = board.board_members.find { |member| member.role == 'owner' }.user
      end
    end
    return board_owners
  end


  def member_is_project_or_board_owner?(members)
    project_owners = self.get_project_owners
    board_owners = self.get_board_owners
    
    projects = self.projects
    result = []
    if !members.empty?
      members.each do |member|
        if project_owners.empty?
          result[member.user_id] = false
        else
          result[member.user_id] = !project_owners.find { |owner| !owner.nil? && owner.id == member.user_id }.nil?
          unless result[member.user_id]
            result[member.user_id] = !board_owners.find { |owner| !owner.nil? && owner.id == member.user_id }.nil?
          end
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
      self.projects.each do |project|
        project.boards.each do |board|
          target_delete_members.each do |target_delete_member|
            bd_member = BoardMember.find_by(board_id: board.id, user_id: target_delete_member)
            if bd_member && !bd_member.destroy
              result = false
            end
          end
        end
        target_delete_members.each do |target_delete_member|
          pj_member = ProjectMember.find_by(project_id: project.id, user_id: target_delete_member)
          if pj_member && !pj_member.destroy
            result = false
          end
        end
      end
     
    end
    return result
  end
end
