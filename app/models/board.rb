class Board < ApplicationRecord
  include ActiveModel::Validations
  validate :instance_validations, on: :create
  belongs_to :project
  has_many :board_members, dependent: :destroy
  has_many :users, through: :board_members

  validates :name, presence: true, length: {maximum: 30}
  validates :description, presence: true 

  def build_member
    members = []
    BoardMember.roles.keys.each do |role|
      temp_members = self.board_members.select { |member| member.role == role }
      members.concat(temp_members)
    end
    return members
  end

  def ensure_no_member
    if !self.board_members || self.board_members.empty?
      self.errors.add(:user_ids, :no_owner, message: "No member in this board")
      return false
    else
      return true
    end
  end
  def instance_validations
    validates_with ::BoardMemberValidator
  end
end
