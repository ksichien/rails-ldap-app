class LdapSearch
  include ActiveModel::Model

  attr_accessor :fname, :lname, :name, :ldap_password

  validates :ldap_password, presence: true

  validates :fname, length: { maximum: 255 }
  validates :lname, length: { maximum: 255 }
  validates :name, length: { maximum: 255 }

  include LdapConnection
  include MailHelpdesk

  def search(name, ldap_username, ldap_password)
    result = ''
    ldap = ldap_login(ldap_username, ldap_password)
    filter = Net::LDAP::Filter.eq('cn', "*#{name}*")
    ldap.search(base: SERVERDC, filter: filter, return_result: true) do |entry|
      result << "#{entry.dn}\n"
    end
    result << "Operation search directory for '#{name}' " \
              "result: #{ldap.get_operation_result.message}\n"
    result.to_s
  end
end
