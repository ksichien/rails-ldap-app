class LdapUser
  include ActiveModel::Model

  attr_accessor :fname, :lname, :groups, :source, :target, :ldap_password

  validates :ldap_password, presence: true

  validates :fname, length: { maximum: 255 }
  validates :lname, length: { maximum: 255 }

  include LdapConnection
  include LdapProcessing
  include MailHelpdesk

  def add_groups(fname, lname, groups, ldap_username, ldap_password)
    result = ''
    ldap = ldap_login(ldap_username, ldap_password)
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

  def copy_groups(source, target, ldap_username, ldap_password)
    result = ''
    ldap = ldap_login(ldap_username, ldap_password)
    groups = search_groups(source.split('.').first,
                           source.split('.').last,
                           ldap_username,
                           ldap_password)
    if groups.empty?
      result = "No changes were made, source user did not have any groups.\n"
    else
      group_array = groups.split("\n")
      group_array.pop # remove last element, operation result from search_groups
      group_array.each do |group|
        ldap.add_attribute group, :member, "uid=#{target}," \
                                            "#{USEROU},#{SERVERDC}"
        result << "Operation add #{target} to\n" \
                  "#{group}\n result: #{ldap.get_operation_result.message}\n"
      end
    end
    result.to_s
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
    ldap = ldap_login(ldap_username, ldap_password)
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
    dn = search_groups(fname, lname, ldap_username, ldap_password)
    ldap = ldap_login(ldap_username, ldap_password)
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

  def update(fname, lname, ldap_username, ldap_password)
    pwd = generate_ldap_password
    user_dn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    ldap = ldap_login(ldap_username, ldap_password)
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
    ldap = ldap_login(ldap_username, ldap_password)
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

  def search_groups(fname, lname, ldap_username, ldap_password)
    result = ''
    ldap = ldap_login(ldap_username, ldap_password)
    filter = Net::LDAP::Filter.eq('member',
                                  "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}")
    ldap.search(base: SERVERDC, filter: filter, return_result: true) do |entry|
      result << "#{entry.dn}\n"
    end
    result << "Operation search directory for '#{name}' " \
              "result: #{ldap.get_operation_result.message}\n"
    result.to_s
  end
end
