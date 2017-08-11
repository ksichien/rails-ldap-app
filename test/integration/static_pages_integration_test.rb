require 'test_helper'

class StaticPagesIntegrationTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:jd)
    sign_in @user
  end

  test "should get root" do
    get root_path
    assert_template 'home'
    assert_response :success
  end
end
