class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user
  enum role: { owner: 0, manager: 1, regular: 2 }
end
