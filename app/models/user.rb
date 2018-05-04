class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true, uniqueness: true

  before_validation :ldap_before_save
  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(username, 'mail').first
  end

  # solution for remember_token issue
  def authenticatable_salt
    Digest::SHA1.hexdigest(email)[0, 29]
  end
end
