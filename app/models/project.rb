class Project < ApplicationRecord
  include ActiveModel::Validations
  validates_with MemberValidator
  # belongs_to :owner, class_name: "User"
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

  def ensure_no_member
    if !self.project_members || self.project_members.empty?
      self.errors.add(:user_ids, :no_owner, message: "No member in this project")
      return false
    else
      return true
    end
  end
end
