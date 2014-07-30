class InvalidCredentials < Exception; end

class User < CouchRest::Model::Base
  use_database $COUCHDB

  property :first_name,         String
  property :last_name,          String
  property :email,              String
  property :username,           String
  property :encrypted_password, String
  property :auth_token,         String
  property :token_set,          DateTime

  timestamps!

  design do
    view :by_username
    view :by_auth_token
  end

  attr_accessor :password, :password_confirmation

  before_validation :encrypt_password

  validates :first_name, :last_name, :email, :encrypted_password, presence: true
  validates :token_set, presence: true, unless: Proc.new {|u| u.auth_token.blank?}

  require 'bcrypt'
  include BCrypt

  def self.authenticate!(username, password)
    user = by_username.key(username).first
    raise InvalidCredentials.new('Invalid username or password') unless user && user.password_matches?(password)
    user
  end

  def self.get_with_token(token)
    by_auth_token.key(token).first
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


