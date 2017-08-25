require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /home before log in" do
    it "redirects to new user session path" do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /home after log in" do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it "retrieves the root path" do
      get root_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it "renders the home template" do
      get root_path
      expect(response).to render_template("home")
    end
  end
end
