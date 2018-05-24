require 'spec_helper'
require 'ldap_connection'
require 'ldap_processing'

describe "processing groups" do
  let(:dummy_class) { Class.new { include LdapProcessing } }
  it "should return the correct group" do
    expected_group = 'cn=Finance,ou=Managers,ou=Germany,ou=groups,dc=ldap,dc=vandelayindustries,dc=com'
    input_group = 'Finance,Managers,Germany'
    output_group = dummy_class.new.process_groups input_group
    expect(output_group).to eq(expected_group)
  end
end

describe "processing users" do
  let(:dummy_class) { Class.new { include LdapProcessing } }
  it "should return the correct users" do
    expected_user_array = [
      'uid=art.vandelay,ou=users,dc=ldap,dc=vandelayindustries,dc=com',
      'uid=h.e.pennypacker,ou=users,dc=ldap,dc=vandelayindustries,dc=com',
      'uid=ken.varnsen,ou=users,dc=ldap,dc=vandelayindustries,dc=com'
    ]
    input_user_array = "art.vandelay\nh.e.pennypacker\nken.varnsen"
    output_user_array = dummy_class.new.process_users input_user_array
    expect(output_user_array).to eq(expected_user_array)
  end
end
