class LdapUser
  include ActiveModel::Model

  attr_accessor :fname, :lname, :groups, :ldap_password

  validates :fname, length: { maximum: 255 }
  validates :lname, length: { maximum: 255 }

  include LdapConnection
  include LdapProcessing
  include MailHelpdesk

  def add_groups(fname, lname, groups, ldap_username, ldap_password)
    result = ''
    ldap = login_ldap(ldap_username, ldap_password)
    if groups.empty?
      result = "No changes were made, no groups were given.\n"
    else
      group_array = groups.split("\n")
      group_array.each do |g|
        attr_dn = process_groups g
        ldap.add_attribute attr_dn,
                           :member,
                           "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
        result << "Operation add #{fname}.#{lname} to\n#{attr_dn}\n " \
                  "result: #{ldap.get_operation_result.message}\n"
      end
      result.to_s
    end
  end

  def create(fname, lname, groups, ldap_username, ldap_password)
    result = ''
    pwd = generate_ldap_password
    user_dn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    result << "Username: #{fname}.#{lname}\n"
    result << "Password: #{pwd[0]}\n\n"
    result << "All operation results below for diagnostics:\n"
    attr = {
      objectclass: ['inetOrgPerson'],
      uid: "#{fname}.#{lname}",
      cn: "#{fname.capitalize} #{lname.capitalize}",
      sn: lname.capitalize,
      mail: "#{fname}.#{lname}@#{EMAIL}"
    }
    ldap = login_ldap(ldap_username, ldap_password)
    ldap.add(dn: user_dn, attributes: attr)
    result << "Operation create user #{fname}.#{lname} result: " \
              "#{ldap.get_operation_result.message}\n"
    ldap.add_attribute user_dn, :userPassword, "{CRYPT}#{pwd[1]}"
    result << "Operation set password #{pwd[0]} result: " \
              "#{ldap.get_operation_result.message}\n"
    result << add_groups(fname, lname, groups, ldap_username, ldap_password)
    result.to_s
  end

  def destroy(fname, lname, ldap_username, ldap_password)
    result = ''
    remove_result = ''
    dn = LdapSearch.search_group(fname, lname, ldap_username, ldap_password)
    ldap = login_ldap(ldap_username, ldap_password)
    if dn.empty?
      remove_result = "No changes were made, no groups were found.\n"
    else
      group_array = dn.split("\n")
      group_array.each do |g|
        group_dn = g
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify dn: group_dn, operations: ops
        remove_result << "Operation remove #{fname}.#{lname} from " \
                        "#{group_dn}\n result: " \
                        "#{ldap.get_operation_result.message}\n"
      end
      remove_result.to_s
    end
    result << remove_result
    filter = Net::LDAP::Filter.eq('uid', "#{fname}.#{lname}")
    ldap.search(base: SERVERDC,
                filter: filter,
                attributes: ['*', '+'],
                return_result: true) do |entry|
      result << mail_uuid("#{fname}.#{lname}", entry.entryUUID)
    end
    ldap.delete dn: "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    result << "Operation destroy user #{fname}.#{lname} result: " \
              "#{ldap.get_operation_result.message}\n"
    result.to_s
  end

  def update_user(fname, lname, ldap_username, ldap_password)
    pwd = generate_ldap_password
    user_dn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    ldap = login_ldap(ldap_username, ldap_password)
    ops = [
      [:replace, :userPassword, "{CRYPT}#{pwd[1]}"]
    ]
    ldap.modify dn: user_dn, operations: ops
    result = "Operation set password #{pwd[0]}\nfor user " \
             "#{fname}.#{lname}\nresult: #{ldap.get_operation_result.message}"
    result.to_s
  end

  def remove_groups(fname, lname, groups, ldap_username, ldap_password)
    result = ''
    ldap = login_ldap(ldap_username, ldap_password)
    if dn.empty?
      result = "No changes were made, no groups were given.\n"
    else
      group_array = dn.split("\n")
      group_array.each do |g|
        attr_dn = process_groups g
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify dn: attr_dn, operations: ops
        result << "Operation remove #{fname}.#{lname} from\n#{attr_dn}\n " \
                  "result: #{ldap.get_operation_result.message}\n"
      end
      result.to_s
    end
  end
end
