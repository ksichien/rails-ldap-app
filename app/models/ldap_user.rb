class LdapUser
  include ActiveModel::Model

  attr_accessor :fname, :lname, :dn, :group_members, :group_name, :password

  validates :fname, length: { maximum: 255 }
  validates :lname, length: { maximum: 255 }

  include LdapWrapper

  def add_group fname, lname, dn, user, password
    result = ''
    ldap = create_ldap_object(user, password)
    if dn.empty?
      result = 'No changes were made, no groups were given.\n'
    else
      grouparray = dn.split('\n')
      grouparray.each do |g|
        attrdn = process_groups g
        ldap.add_attribute attrdn, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
        result << "Operation add #{fname}.#{lname} to\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end
      result.to_s
    end
  end

  def add_group_multiple group_members, group_name, user, password
    result = ''
    ldap = create_ldap_object(user, password)
    members = group_members.split('\n')
    memberarray = []
    members.each do |m|
      userdn = "uid=#{m.chomp},#{USEROU},#{SERVERDC}"
      memberarray << userdn
    end
    groupdn = process_groups group_name
    memberarray.each do |m|
      ldap.add_attribute groupdn, :member, m
      username = m.gsub('uid=','')
      username.gsub!(",#{USEROU},#{SERVERDC}",'')
      result << "Operation add #{username} to\n#{groupdn}\n result: #{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end

  def create fname, lname, dn, user, password
    result = ''
    pwd = create_ldap_password
    userdn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    result << "Username: #{fname}.#{lname}\n"
    result << "Password: #{pwd[0]}\n\n"
    result << "All operation results below for diagnostics:\n"
    attr = {
      :objectclass => ["inetOrgPerson"],
      :uid => "#{fname}.#{lname}",
      :cn => "#{fname.capitalize} #{lname.capitalize}",
      :sn => "#{lname.capitalize}",
      :mail => "#{fname}.#{lname}@#{EMAIL}"
    }
    ldap = create_ldap_object(user, password)
    ldap.add(:dn => userdn, :attributes => attr)
    result << "Operation create user #{fname}.#{lname} result: #{ldap.get_operation_result.message}\n"
    ldap.add_attribute userdn, :userPassword, "{CRYPT}#{pwd[1]}"
    result << "Operation set password #{pwd[0]} result: #{ldap.get_operation_result.message}\n"
    result << add_group(fname, lname, dn, user, password)
    result.to_s
  end

  def create_group group_name, group_members, user, password
    result = ''
    groupdn = process_groups group_name
    if group_members.empty?
      group_members = 'no-reply'
    end
    memberarray = process_users group_members
    attr = {
      :objectclass => ['top', 'groupOfNames'],
      :cn => "#{group_name}",
      :member => memberarray
    }
    ldap = create_ldap_object(user, password)
    ldap.add(:dn => groupdn, :attributes => attr)
    result << "Operation create group #{group_name} result: #{ldap.get_operation_result.message}\n"
    result << "The following members were added to the group:\n"
    memberarray.each do |m|
      result << "#{m}\n"
    end
    result.to_s
  end


  def destroy fname, lname, user, password
    result = ''
    removeresult = ''
    dn = search_group(fname, lname, user, password)
    ldap = create_ldap_object(user, password)
    if dn.empty?
      removeresult = 'No changes were made, no groups were found.\n'
    else
      grouparray = dn.split('\n')
      grouparray.each do |g|
        groupdn = g
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify :dn => groupdn, :operations => ops
        removeresult << "Operation remove #{fname}.#{lname} from\n#{groupdn}\n result: #{ldap.get_operation_result.message}\n"
      end
      removeresult.to_s
    end
    result << removeresult
    filter = Net::LDAP::Filter.eq('uid', "#{fname}.#{lname}")
    ldap.search( :base => SERVERDC, :filter => filter, :attributes => ['*','+'], :return_result => true ) do |entry|
      result << mail_uuid(fname, lname, entry.entryUUID)
    end
    ldap.delete :dn => "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    result << "Operation destroy user #{fname}.#{lname} result: #{ldap.get_operation_result.message}\n"
    result.to_s
  end

  def destroy_group group_name, user, password
    ldap = create_ldap_object(user, password)
    groupdn = process_groups group_name
    ldap.delete :dn => groupdn
    result = "Operation destroy group\n#{groupdn}\nresult: #{ldap.get_operation_result.message}\n"
  end

  def update fname, lname, user, password
    pwd = create_ldap_password
    userdn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    ldap = create_ldap_object(user, password)
    ops = [
      [:replace, :userPassword, "{CRYPT}#{pwd[1]}"]
    ]
    ldap.modify :dn => userdn, :operations => ops
    result = "Operation set password #{pwd[0]}\nfor user #{fname}.#{lname}\nresult: #{ldap.get_operation_result.message}"
  end

  def remove_group fname, lname, dn, user, password
    result = ''
    ldap = create_ldap_object(user, password)
    if dn.empty?
      result = 'No changes were made, no groups were given.\n'
    else
      grouparray = dn.split("\n")
      for g in grouparray do
        attrdn = process_groups g
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify :dn => attrdn, :operations => ops
        result << "Operation remove #{fname}.#{lname} from\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end
      result.to_s
    end
  end

  def remove_group_multiple group_members, group_name, user, password
    result = ''
    ldap = create_ldap_object(user, password)
    groupdn = process_groups group_name
    memberarray = process_users group_members
    memberarray.each do |m|
      ops = [
        [:delete, :member, m]
      ]
      ldap.modify :dn => groupdn, :operations => ops
      username = m.gsub('uid=','')
      username.gsub!(",#{USEROU},#{SERVERDC}",'')
      result << "Operation remove #{username} from\n#{groupdn}\n result: #{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end

  def search group_name, user, password
    result = ''
    ldap = create_ldap_object(user, password)
    filter = Net::LDAP::Filter.eq('cn', "*#{group_name}*")
    ldap.search( :base => SERVERDC, :filter => filter, :return_result => true ) do |entry|
      result << "#{entry.dn}\n"
    end
    if result.empty?
      result << "Operation search directory for '#{group_name}' result: #{ldap.get_operation_result.message}\n"
    end
    result.to_s
  end

  def search_group fname, lname, user, password
    result = ''
    ldap = create_ldap_object(user, password)
    filter = Net::LDAP::Filter.eq('member', "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}")
    ldap.search( :base => SERVERDC, :filter => filter, :return_result => true ) do |entry|
      result << "#{entry.dn}\n"
    end
    result.to_s
  end

private

  def create_ldap_password
    pwd = SecureRandom.urlsafe_base64(20)
    hashpwd = pwd.crypt('$6$' + SecureRandom.random_number(36 ** 8).to_s(36))
    pwdarray = [pwd, hashpwd]
  end

  def mail_uuid fname, lname, uuid
    msg = "Subject: Account #{fname}.#{lname} has been deleted.\n\nThe account's entryUUID is #{uuid}."
    smtp = Net::SMTP.new 'smtp.example.com', 587
    smtp.enable_starttls
    smtp.start('example.com', 'rails-ldap-app', Figaro.env.ldap_admin_password, :login) do
      smtp.send_message(msg, 'rails-ldap-app@example.com', 'helpdesk@example.com')
    end
    return "Mail sent to helpdesk@example.com with entry UUID.\n"
  end

  def process_groups g
    path = ''
    ldapgroup = g.split(',')
    if ldapgroup[1].nil?
      path = ldapgroup[0].chomp
    else
      path << ldapgroup[0]
      ldapunits = ldapgroup.drop(1)
      ldapunits.each do |l|
        path << ",ou=#{l.chomp}"
      end
    end
    attrdn = "cn=#{path},#{GROUPOU},#{SERVERDC}"
  end

  def process_users g
    users = g.split('\n')
    userarray = []
    users.each do |m|
      userdn = "uid=#{m.chomp},#{USEROU},#{SERVERDC}"
      userarray << userdn
    end
    userarray
  end
end
