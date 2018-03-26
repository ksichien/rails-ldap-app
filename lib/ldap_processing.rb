module LdapProcessing
  private def process_users(users)
    user_array = users.split("\n")
    result_array = []
    user_array.each do |user|
      user_dn = "uid=#{user.chomp},#{USEROU},#{SERVERDC}"
      result_array << user_dn
    end
    result_array
  end

  private def process_groups(name)
    path = ''
    ldap_group = name.split(',')
    if ldap_group[1].nil?
      path = ldap_group[0].chomp
    else
      path << ldap_group[0]
      ldap_units = ldap_group.drop(1)
      ldap_units.each do |unit|
        path << ",ou=#{unit.chomp}"
      end
    end
    "cn=#{path},#{GROUPOU},#{SERVERDC}"
  end
end
