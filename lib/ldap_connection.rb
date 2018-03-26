module LdapConnection
  SERVERHOSTNAME = 'ldap.vandelayindustries.com'.freeze
  SERVERDC = 'dc=ldap,dc=vandelayindustries,dc=com'.freeze
  GROUPOU = 'ou=groups'.freeze
  USEROU = 'ou=users'.freeze
  EMAIL = 'vandelayindustries.com'.freeze

  private def ldap_login(user, password)
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

  private def generate_ldap_password
    pwd = SecureRandom.hex(24)
    hashpwd = pwd.crypt('$6$' + SecureRandom.random_number(36**8).to_s(36))
    [pwd, hashpwd]
  end
end
