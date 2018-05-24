require 'spec_helper'
require 'ldap_connection'
require 'securerandom'

describe "generate password" do
  let(:dummy_class) { Class.new { include LdapProcessing } }
  it "should return a correct password" do
    expected_password = /[0-9a-f]{48}/
    output_password = dummy_class.new.generate_ldap_password
    expect(output_password.first).to match(expected_password)
  end
end
