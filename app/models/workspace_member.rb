class WorkspaceMember < ApplicationRecord
  belongs_to :workspace
  belongs_to :user
  enum role: { owner: 0, manager: 1, regular: 2 }
end
