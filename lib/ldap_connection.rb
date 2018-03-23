module LdapConnection
  SERVERHOSTNAME = 'ldap.vandelayindustries.com'.freeze
  SERVERDC = 'dc=ldap,dc=vandelayindustries,dc=com'.freeze
  GROUPOU = 'ou=groups'.freeze
  USEROU = 'ou=users'.freeze
  EMAIL = 'vandelayindustries.com'.freeze

  def ldap_login(user, password)
    Net::LDAP.new host: SERVERHOSTNAME,
                  port: 636,
                  encryption: :simple_tls,
                  base: SERVERDC,
                  auth: {
                    method: :simple,
                    username: "uid=#{user},#{USEROU},#{SERVERDC}",
                    password: password
                  }
  end
end
