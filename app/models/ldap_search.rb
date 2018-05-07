class LdapSearch
  include ActiveModel::Model

  attr_accessor :name, :ldap_password

  validates :ldap_password, presence: true

  validates :name, length: { maximum: 255 }

  include LdapConnection
  include MailHelpdesk

  def search(name, ldap_username, ldap_password)
    result = ''
    ldap = ldap_login(ldap_username, ldap_password)
    filter = Net::LDAP::Filter.eq('cn', "*#{name}*")
    ldap.search(base: SERVERDC, filter: filter, return_result: true) do |entry|
      if entry.dn.include? USEROU
        result << "User name: #{entry.dn.gsub! ",#{USEROU},#{SERVERDC}", ''}\n"
      elsif entry.dn.include? GROUPOU
        result << "Group name: #{entry.dn.gsub! ",#{GROUPOU},#{SERVERDC}", ''}\n"
      else
        result << "Unusual Object name: #{entry.dn}\n"
      end
    end
    result << "Operation search directory for '#{name}' " \
              "result: #{ldap.get_operation_result.message}\n"
    result.to_s
  end
end
