class BoardMember < ApplicationRecord
  belongs_to :board
  belongs_to :user
  enum role: { owner: 0, manager: 1, regular: 2 }
end
