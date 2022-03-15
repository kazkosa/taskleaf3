class Project < ApplicationRecord
  include ActiveModel::Validations
  validate :instance_validations, on: :create
  belongs_to :workspace, optional: true
  has_many :boards, foreign_key: :project_id, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members

  validates :name, presence: true, length: {maximum: 30}
  validates :description, presence: true 

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
end
