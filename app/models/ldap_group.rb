class LdapGroup
  include ActiveModel::Model

  attr_accessor :name, :users, :ldap_password

  validates :name, length: { maximum: 255 }

  include LdapConnection
  include LdapProcessing
  include MailHelpdesk

  def add_users(name, users, ldap_username, ldap_password)
    result = ''
    ldap = login_ldap(ldap_username, ldap_password)
    member_array = process_users users
    group_dn = process_groups name
    member_array.each do |m|
      ldap.add_attribute group_dn, :member, m
      username = m.gsub('uid=', '')
      username.gsub!(",#{USEROU},#{SERVERDC}", '')
      result << "Operation add #{username} to\n#{group_dn}\n result: " \
                "#{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end

  def create_group(name, users, ldap_username, ldap_password)
    result = ''
    users = 'no-reply' if users.empty?
    member_array = process_users users
    group_dn = process_groups name
    attr = {
      objectclass: %w[top groupOfNames],
      cn: name,
      member: member_array
    }
    ldap = login_ldap(ldap_username, ldap_password)
    ldap.add(dn: group_dn, attributes: attr)
    result << "Operation create group #{name} result: " \
              "#{ldap.get_operation_result.message}\n"
    result << "The following members were added to the group:\n"
    member_array.each do |m|
      result << "#{m}\n"
    end
    result.to_s
  end

  def destroy_group(name, ldap_username, ldap_password)
    ldap = login_ldap(ldap_username, ldap_password)
    group_dn = process_groups name
    ldap.delete dn: group_dn
    result = "Operation destroy group\n#{group_dn}\nresult: " \
             "#{ldap.get_operation_result.message}\n"
    result.to_s
  end

  def remove_users(name, users, ldap_username, ldap_password)
    result = ''
    ldap = login_ldap(ldap_username, ldap_password)
    member_array = process_users users
    group_dn = process_groups name
    member_array.each do |m|
      ops = [
        [:delete, :member, m]
      ]
      ldap.modify dn: group_dn, operations: ops
      username = m.gsub('uid=', '')
      username.gsub!(",#{USEROU},#{SERVERDC}", '')
      result << "Operation remove #{username} from\n#{group_dn}\n " \
                "result: #{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end
end
