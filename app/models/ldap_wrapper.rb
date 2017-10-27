module LdapWrapper

  SERVERHOSTNAME = 'ldap.vandelayindustries.com'
  SERVERDC = 'dc=internal,dc=vandelayindustries,dc=com'
  GROUPOU = 'ou=groups'
  USEROU = 'ou=users'
  EMAIL = 'vandelayindustries.com'

  def create_ldap_object(user, password)
    ldap = Net::LDAP.new :host => SERVERHOSTNAME,
                         :port => 636,
                         :encryption => :simple_tls,
                         :base => SERVERDC,
                         :auth => {
                               :method => :simple,
                               :username => "uid=#{user},#{USEROU},#{SERVERDC}",
                               :password => password
                          }
  end
end
