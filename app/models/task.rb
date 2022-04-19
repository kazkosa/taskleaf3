class Task < ApplicationRecord
  validates :title, presence: true
  belongs_to :board
  belongs_to :state, optional: true
  belongs_to :user, optional: true
end
