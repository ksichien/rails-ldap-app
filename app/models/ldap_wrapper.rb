module LdapWrapper

  SERVERHOSTNAME = "ldap.example.com"
  SERVERDC = "dc=example,dc=com"
  GROUPOU = "ou=groups"
  USEROU = "ou=users"
  EMAIL = "example.com"

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
