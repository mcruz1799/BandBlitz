class User < ApplicationRecord
  has_secure_password
  belongs_to :band

  validates_presence_of :first_name, :last_name, :email
  validates_uniqueness_of :email
  validates_format_of :email, with: /\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))\z/i, message: "is not a valid format"


  def proper_name
    "#{first_name} #{last_name}"
  end

  def self.authenticate(email,password)
    find_by_email(email).try(:authenticate, password)
  end

  ROLES = [['Administrator', :admin],['Band Manager', :manager],['Band Member', :member]]

  def role?(authorized_role)
    return false if role.nil?
    role.to_sym == authorized_role
  end
  
end
