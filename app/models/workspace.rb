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
end
