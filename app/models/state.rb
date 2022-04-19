class State < ApplicationRecord
  validates :name, presence: true, length: {maximum: 30}
  validates :sort, numericality: { only_integer: true }
  belongs_to :board
  has_many :tasks
end
