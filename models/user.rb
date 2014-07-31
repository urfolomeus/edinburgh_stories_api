class InvalidCredentials < Exception; end

require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  attr_accessor :password, :password_confirmation

  before_validation :encrypt_password

  validates :first_name, :last_name, :email, :encrypted_password, presence: true
  validates :token_set, presence: true, unless: Proc.new {|u| u.auth_token.blank?}
  validates :username, presence: true, uniqueness: true

  def self.authenticate!(username, password)
    user = where(username: username).first
    raise InvalidCredentials.new('Invalid username or password') unless user && user.password_matches?(password)
    user
  end

  def self.get_with_token(token)
    where(auth_token: token).first
  end

  def login!
    set_token_and_time(SecureRandom.hex, Time.now)
  end

  def logout!
    set_token_and_time(nil, nil)
  end

  def logged_in?
    self.auth_token.present?
  end

  def password_matches?(password)
    Password.new(self.encrypted_password) == password
  end

  private

  def set_token_and_time(token, time)
    self.auth_token = token
    self.token_set = time
    self.save!
  end

  def encrypt_password
    return if password.blank?
    if password == password_confirmation
      self.encrypted_password = Password.create(password)
    else
      errors.add(:password_confirmation, "doesn't match Password")
    end
  end
end

