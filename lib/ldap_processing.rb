module LdapProcessing
  include LdapConnection

  def process_users(users)
    user_array = users.split("\n")
    user_array.map { |u| "uid=#{u.chomp},#{USEROU},#{SERVERDC}" }
  end

  def process_groups(name)
    path = ''
    ldap_group = name.split(',')
    if ldap_group[1].nil?
      path = ldap_group.first.chomp
    else
      path << ldap_group.first
      ldap_units = ldap_group.drop(1)
      ldap_units.each do |unit|
        path << ",ou=#{unit.chomp}"
      end
    end
    "cn=#{path},#{GROUPOU},#{SERVERDC}"
  end
end
