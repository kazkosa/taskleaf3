class Project < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :workspace, optional: true
  has_many :boards, foreign_key: :project_id, dependent: :destroy
end
