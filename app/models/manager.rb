class Manager < ApplicationRecord
  has_secure_password
  validates :login_id, presence: true, length: {maximum: 30}, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
end
