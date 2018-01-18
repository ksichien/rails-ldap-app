class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
     :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true, uniqueness: true

  before_validation :ldap_before_save
  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(self.username,'mail').first
  end

  # use ldap uid as primary key
  # before_validation :get_ldap_id
  # def get_ldap_id
  #   self.id = Devise::LDAP::Adapter.get_ldap_param(self.username,'uidnumber').first
  # end

  # hack for remember_token
  def authenticatable_salt
    Digest::SHA1.hexdigest(email)[0,29]
  end
end
