class LdapUser
  include ActiveModel::Model

  attr_accessor :fname, :lname, :dn, :group_members, :group_name, :password

  validates :fname, length: { maximum: 255 }
  validates :lname, length: { maximum: 255 }

  include LdapWrapper

  def add_group(fname, lname, dn, user, password)
    result = ''
    ldap = create_ldap_object(user, password)
    if dn.empty?
      result = "No changes were made, no groups were given.\n"
    else
      grouparray = dn.split("\n")
      grouparray.each do |g|
        attrdn = process_groups g
        ldap.add_attribute attrdn,
                           :member,
                           "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
        result << "Operation add #{fname}.#{lname} to\n#{attrdn}\n " \
                  "result: #{ldap.get_operation_result.message}\n"
      end
      result.to_s
    end
  end

  def add_group_multiple(group_members, group_name, user, password)
    result = ''
    ldap = create_ldap_object(user, password)
    members = group_members.split("\n")
    memberarray = []
    members.each do |m|
      userdn = "uid=#{m.chomp},#{USEROU},#{SERVERDC}"
      memberarray << userdn
    end
    groupdn = process_groups group_name
    memberarray.each do |m|
      ldap.add_attribute groupdn, :member, m
      username = m.gsub('uid=','')
      username.gsub!(",#{USEROU},#{SERVERDC}", '')
      result << "Operation add #{username} to\n#{groupdn}\n result: " \
                "#{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end

  def create(fname, lname, dn, user, password)
    result = ''
    pwd = create_ldap_password
    userdn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
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
    ldap = create_ldap_object(user, password)
    ldap.add(dn: userdn, attributes: attr)
    result << "Operation create user #{fname}.#{lname} result: " \
              "#{ldap.get_operation_result.message}\n"
    ldap.add_attribute userdn, :userPassword, "{CRYPT}#{pwd[1]}"
    result << "Operation set password #{pwd[0]} result: " \
              "#{ldap.get_operation_result.message}\n"
    result << add_group(fname, lname, dn, user, password)
    result.to_s
  end

  def create_group(group_name, group_members, user, password)
    result = ''
    groupdn = process_groups group_name
    group_members = 'no-reply' if group_members.empty?
    memberarray = process_users group_members
    attr = {
      objectclass: %w[top groupOfNames],
      cn: group_name,
      member: memberarray
    }
    ldap = create_ldap_object(user, password)
    ldap.add(dn: groupdn, attributes: attr)
    result << "Operation create group #{group_name} result: " \
              "#{ldap.get_operation_result.message}\n"
    result << "The following members were added to the group:\n"
    memberarray.each do |m|
      result << "#{m}\n"
    end
    result.to_s
  end

  def destroy(fname, lname, user, password)
    result = ''
    removeresult = ''
    dn = search_group(fname, lname, user, password)
    ldap = create_ldap_object(user, password)
    if dn.empty?
      removeresult = "No changes were made, no groups were found.\n"
    else
      grouparray = dn.split("\n")
      grouparray.each do |g|
        groupdn = g
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify dn: groupdn, operations: ops
        removeresult << "Operation remove #{fname}.#{lname} from " \
                        "#{groupdn}\n result: " \
                        "#{ldap.get_operation_result.message}\n"
      end
      removeresult.to_s
    end
    result << removeresult
    filter = Net::LDAP::Filter.eq('uid', "#{fname}.#{lname}")
    ldap.search(base: SERVERDC,
                filter: filter,
                attributes: ['*','+'],
                return_result: true) do |entry|
      result << mail_uuid(fname, lname, entry.entryUUID)
    end
    ldap.delete dn: "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    result << "Operation destroy user #{fname}.#{lname} result: " \
              "#{ldap.get_operation_result.message}\n"
    result.to_s
  end

  def destroy_group(group_name, user, password)
    ldap = create_ldap_object(user, password)
    groupdn = process_groups group_name
    ldap.delete dn: groupdn
    result = "Operation destroy group\n#{groupdn}\nresult: " \
             "#{ldap.get_operation_result.message}\n"
    result.to_s
  end

  def update(fname, lname, user, password)
    pwd = create_ldap_password
    userdn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    ldap = create_ldap_object(user, password)
    ops = [
      [:replace, :userPassword, "{CRYPT}#{pwd[1]}"]
    ]
    ldap.modify dn: userdn, operations: ops
    result = "Operation set password #{pwd[0]}\nfor user " \
             "#{fname}.#{lname}\nresult: #{ldap.get_operation_result.message}"
    result.to_s
  end

  def remove_group(fname, lname, dn, user, password)
    result = ''
    ldap = create_ldap_object(user, password)
    if dn.empty?
      result = "No changes were made, no groups were given.\n"
    else
      grouparray = dn.split("\n")
      grouparray.each do |g|
        attrdn = process_groups g
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify dn: attrdn, operations: ops
        result << "Operation remove #{fname}.#{lname} from\n#{attrdn}\n " \
                  "result: #{ldap.get_operation_result.message}\n"
      end
      result.to_s
    end
  end

  def remove_group_multiple(group_members, group_name, user, password)
    result = ''
    ldap = create_ldap_object(user, password)
    groupdn = process_groups group_name
    memberarray = process_users group_members
    memberarray.each do |m|
      ops = [
        [:delete, :member, m]
      ]
      ldap.modify dn: groupdn, operations: ops
      username = m.gsub('uid=','')
      username.gsub!(",#{USEROU},#{SERVERDC}",'')
      result << "Operation remove #{username} from\n#{groupdn}\n " \
                "result: #{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end

  def search(group_name, user, password)
    result = ''
    ldap = create_ldap_object(user, password)
    filter = Net::LDAP::Filter.eq('cn', "*#{group_name}*")
    ldap.search(base: SERVERDC, filter: filter, return_result: true) do |entry|
      result << "#{entry.dn}\n"
    end
    if result.empty?
      result << "Operation search directory for '#{group_name}' " \
                "result: #{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end

  def search_group(fname, lname, user, password)
    result = ''
    ldap = create_ldap_object(user, password)
    filter = Net::LDAP::Filter.eq('member',
                                  "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}")
    ldap.search(base: SERVERDC, filter: filter, return_result: true) do |entry|
      result << "#{entry.dn}\n"
    end
    result.to_s
  end

  private

  def create_ldap_password
    pwd = SecureRandom.hex(24)
    hashpwd = pwd.crypt('$6$' + SecureRandom.random_number(36**8).to_s(36))
    [pwd, hashpwd]
  end

  def mail_uuid(fname, lname, uuid)
    msg = "Subject: Account #{fname}.#{lname} has been deleted.\n\n" \
          "The account's entryUUID is #{uuid}."
    smtp = Net::SMTP.new "smtp.#{Figaro.env.domain}", 587
    smtp.enable_starttls
    smtp.start(Figaro.env.domain,
               Figaro.env.mail_user,
               Figaro.env.mail_password,
               :login) do
      smtp.send_message(msg,
                        "#{Figaro.env.mail_user}@#{Figaro.env.domain}",
                        "#{Figaro.env.mail_helpdesk}@#{Figaro.env.domain}")
    end
    "Mail sent to #{Figaro.env.mail_helpdesk}@#{Figaro.env.domain} " \
    "with entry UUID.\n"
  end

  def process_groups(group)
    path = ''
    ldapgroup = group.split(',')
    if ldapgroup[1].nil?
      path = ldapgroup[0].chomp
    else
      path << ldapgroup[0]
      ldapunits = ldapgroup.drop(1)
      ldapunits.each do |unit|
        path << ",ou=#{unit.chomp}"
      end
    end
    "cn=#{path},#{GROUPOU},#{SERVERDC}"
  end

  def process_users(group)
    users = group.split("\n")
    userarray = []
    users.each do |user|
      userdn = "uid=#{user.chomp},#{USEROU},#{SERVERDC}"
      userarray << userdn
    end
    userarray
  end
end
