class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  # before_save { self.email = email.downcase }
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: 30}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 191 }, 
                    format: { with: VALID_EMAIL_REGEX }, 
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  has_many :workspace_members, dependent: :destroy
  has_many :workspaces, through: :workspace_members

  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members

  has_many :board_members, dependent: :destroy
  has_many :boards, through: :board_members
  has_many :tasks

  # Returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns the hash value of the passed string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Remember users in database for persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the passed token matches the digest
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Make remember_digest null
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activate the account
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Send an activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Save the token for password reset and its issuance time
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Send password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if password reset has expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Send an invitation email
  def send_announcement_email_of_join_the_project_mail(user, project)
    UserMailer.join_the_project(self, user, project).deliver_now
  end

  def send_announcement_email_of_join_the_workspace_mail(user, workspace)
    UserMailer.join_the_workspace(self, user, workspace).deliver_now
  end

  private

  # Convert email addresses to all lowercase
  def downcase_email
    self.email = email.downcase
  end

  # Create and assign activation tokens and digests
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
