class User < ActiveRecord::Base
  
  require 'digest/sha2'
  
  ROLE_CREW = 'crew'
  ROLE_CREW_MANAGER = 'crew manager'
  
  set_table_name "user_security"
  
  attr_protected :password, :salt
  
  attr_accessor :password
  
  before_create :set_create_date
  before_save :create_hashed_password
  after_save :clear_password
  
  def self.authenticate(email, password)
    users = self.where("email = ?", email)
    return false if users.length != 1
    hp = self.make_hash_password(password, users[0].salt)
    return hp == users[0].hashed_password ? users[0] : false
  end
  
  private
  def set_create_date
    self.create_date = Time.now  
  end
  
  def create_hashed_password
    self.modify_date = Time.now
    unless password.blank?
      self.salt = User.make_salt if salt.blank?
      self.hashed_password = User.make_hash_password(password, salt)
    end
  end
  
  def clear_password
    @password = nil
  end

  def self.make_salt
    return Digest::SHA2.hexdigest("salt, time: #{Time.now}")
  end
  
  def self.make_hash_password(password, salt="")
    return Digest::SHA2.hexdigest("oot hash: " + password + " with salt: " + salt);
  end

end
