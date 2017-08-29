require 'test_helper'

class LdapUsersIntegrationTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:jd)
    sign_in @user
  end

  test 'should get add' do
    get add_path
    assert_template 'ldap_users/add'
    assert_response :success
  end

  test 'should get add multiple' do
    get add_multiple_path
    assert_template 'ldap_users/add_multiple'
    assert_response :success
  end

  test 'should get create' do
    get create_path
    assert_template 'ldap_users/new'
    assert_response :success
  end

  test 'should get create_group' do
    get create_group_path
    assert_template 'ldap_users/new_group'
    assert_response :success
  end

  test 'should get destroy' do
    get destroy_path
    assert_template 'ldap_users/delete'
    assert_response :success
  end

  test 'should get destroy group' do
    get destroy_group_path
    assert_template 'ldap_users/delete_group'
    assert_response :success
  end

  test 'should get update' do
    get update_path
    assert_template 'ldap_users/edit'
    assert_response :success
  end

  test 'should get remove' do
    get remove_path
    assert_template 'ldap_users/remove'
    assert_response :success
  end

  test 'should get remove multiple' do
    get remove_multiple_path
    assert_template 'ldap_users/remove_multiple'
    assert_response :success
  end

  test 'should get result' do
    get result_path
    assert_template 'ldap_users/result'
    assert_response :success
  end

  test 'should get search' do
    get search_path
    assert_template 'ldap_users/search'
    assert_response :success
  end

  test 'should get search group' do
    get search_group_path
    assert_template 'ldap_users/search_group'
    assert_response :success
  end
end
