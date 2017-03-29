class LdapUser
  include ActiveModel::Model

  attr_accessor :fname, :lname, :dn

  validates :fname, presence: true, length: { maximum: 255 }
  validates :lname, presence: true, length: { maximum: 255 }

  SERVERLDAP = "dc=example,dc=com"
  EMAIL = "example.com"
  GROUPOU = "ou=Groups"
  USEROU = "ou=Users"

  def add_list fname, lname, dn
    result = ""

    ldap = LdapWrapper.make_ldap

    if dn.empty?
      result = "No changes were made, no lists were given.\n"
    else
      listarray = dn.split("\n")

      listarray.each do |l|
        attrdn = process_lists l
        ldap.add_attribute attrdn, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERLDAP}"
        result << "Operation add #{fname}.#{lname} to\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end

      result.to_s
    end
  end

  def create fname, lname, dn
    result = ""
    pwd = create_ldap_password
    userdn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERLDAP}"

    result << "Username: #{fname}.#{lname}\n"
    result << "Password: #{pwd[0]}\n\n"
    result << "All operation results below for diagnostics:\n"

    attr = {
      :objectclass => ["inetOrgPerson"],
      :uid => "#{fname}.#{lname}",
      :cn => "#{fname} #{lname}",
      :displayName => "#{fname.capitalize} #{lname.capitalize}",
      :givenName => "#{fname.capitalize}",
      :sn => "#{lname.capitalize}",
      :mail => "#{fname}.#{lname}@#{EMAIL}"
    }

    ldap = LdapWrapper.make_ldap

    ldap.add(:dn => userdn, :attributes => attr)
    result << "Operation create user #{fname}.#{lname} result: #{ldap.get_operation_result.message}\n"

    ldap.add_attribute userdn, :userPassword, "{CRYPT}#{pwd[1]}"
    result << "Operation set password #{pwd[0]} result: #{ldap.get_operation_result.message}"

    result << add_list(fname, lname, dn)

    result.to_s
  end

  def destroy_user fname, lname
    result = ""
    removeresult = ""

    dn = search fname, lname

    ldap = LdapWrapper.make_ldap

    if dn.empty?
      removeresult = "No changes were made, no lists were found.\n"
    else
      listarray = dn.split("\n")

      listarray.each do |l|
        attrdn = l
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERLDAP}"]
        ]
        ldap.modify :dn => attrdn, :operations => ops
        removeresult << "Operation remove #{fname}.#{lname} from\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end

      removeresult.to_s
    end

    result << removeresult

    ldap.delete :dn => "uid=#{fname}.#{lname},#{USEROU},#{SERVERLDAP}"
    result << "Operation destroy user #{fname}.#{lname} result: #{ldap.get_operation_result.message}\n"

    result.to_s
  end

  def update fname, lname
    result = ""
    pwd = create_ldap_password
    userdn = "uid=#{fname}.#{lname},#{USEROU},#{SERVERLDAP}"

    ldap = LdapWrapper.make_ldap

    ops = [
      [:replace, :userPassword, "{CRYPT}#{pwd[1]}"]
    ]

    ldap.modify :dn => userdn, :operations => ops
    result << "Operation set password #{pwd[0]} for user #{fname}.#{lname} result: #{ldap.get_operation_result.message}"

    result.to_s
  end

  def remove_list fname, lname, dn
    result = ""

    ldap = LdapWrapper.make_ldap

    if dn.empty?
      result = "No changes were made, no lists were given.\n"
    else
      grouparray = dn.split("\n")

      for l in grouparray do
        attrdn = process_lists l
        ops = [
          [:delete, :member, "uid=#{fname}.#{lname},#{USEROU},#{SERVERLDAP}"]
        ]
        ldap.modify :dn => attrdn, :operations => ops
        result << "Operation remove #{fname}.#{lname} from\n#{attrdn}\n result: #{ldap.get_operation_result.message}\n"
      end

      result.to_s
    end
  end

  def search fname, lname
    result = ""

    ldap = LdapWrapper.make_ldap

    filter = Net::LDAP::Filter.eq("member", "uid=#{fname}.#{lname},#{USEROU},#{SERVERLDAP}")
    ldap.search( :base => SERVERLDAP, :filter => filter, :return_result => true ) do |entry|
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
    attrdn = "cn=#{path},#{GROUPOU},#{SERVERLDAP}"
  end
end
