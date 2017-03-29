class LdapWrapper

  SERVERHOSTNAME = "ldap.example.com"
  SERVERPASSWORD = "password"
  SERVERDC = "dc=example,dc=com"

  def self.make_ldap
    ldap = Net::LDAP.new :host => SERVERHOSTNAME,
         :port => 636,
         :encryption => "simple_tls",
         :base => SERVERDC,
         :auth => {
               :method => :simple,
               :username => "cn=admin,#{SERVERDC}",
               :password => SERVERPASSWORD
    }
  end
end
