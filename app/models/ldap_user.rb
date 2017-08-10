class LdapUser
  include ActiveModel::Model

  attr_accessor :fname, :lname, :dn, :password

  validates :fname, presence: true, length: { maximum: 255 }
  validates :lname, presence: true, length: { maximum: 255 }

  include LdapWrapper

  def add_list fname, lname, dn, user, password
    result = ""

    ldap = create_ldap_object(user, password)

    if dn.empty?
      result = "No changes were made, no lists were given.\n"
    else
      listarray = dn.split("\n")

      listarray.each do |l|
        attrdn = process_lists l
        ldap.add_attribute attrdn, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
        result << "Operation add #{fname}.#{lname} to\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end

      result.to_s
    end
  end

  def create fname, lname, dn, user, password
    result = ""
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
    result << "Operation set password #{pwd[0]} result: #{ldap.get_operation_result.message}"

    result << add_list(fname, lname, dn, user, password)

    result.to_s
  end

  def destroy_user fname, lname, user, password
    result = ""
    removeresult = ""

    dn = search fname, lname

    ldap = create_ldap_object(user, password)

    if dn.empty?
      removeresult = "No changes were made, no lists were found.\n"
    else
      listarray = dn.split("\n")

      listarray.each do |l|
        attrdn = l
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify :dn => attrdn, :operations => ops
        removeresult << "Operation remove #{fname}.#{lname} from\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end

      removeresult.to_s
    end

    result << removeresult

    ldap.delete :dn => "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"
    result << "Operation destroy user #{fname}.#{lname} result: #{ldap.get_operation_result.message}\n"

    result.to_s
  end

  def update fname, lname, user, password
    result = ""
    pwd = create_ldap_password
    userdn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"

    ldap = create_ldap_object(user, password)

    ops = [
      [:replace, :userPassword, "{CRYPT}#{pwd[1]}"]
    ]

    ldap.modify :dn => userdn, :operations => ops
    result << "Operation set password #{pwd[0]} for user #{fname}.#{lname} result: #{ldap.get_operation_result.message}"

    result.to_s
  end

  def remove_list fname, lname, dn, user, password
    result = ""

    ldap = create_ldap_object(user, password)

    if dn.empty?
      result = "No changes were made, no lists were given.\n"
    else
      grouparray = dn.split("\n")

      for l in grouparray do
        attrdn = process_lists l
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}"]
        ]
        ldap.modify :dn => attrdn, :operations => ops
        result << "Operation remove #{fname}.#{lname} from\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end

      result.to_s
    end
  end

  def search fname, lname, user, password
    result = ""

    ldap = create_ldap_object(user, password)

    filter = Net::LDAP::Filter.eq("member", "uid=#{fname}.#{lname},#{USEROU},#{SERVERDC}")
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

  def process_lists l
    path = ""
    ldapgroup = l.split(",")
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
end
