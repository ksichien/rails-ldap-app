require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /home" do
    it "redirects to users sign in page" do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
    it "retrieves the home page" do
      user = build(:jd)
      sign_in user
      get root_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it "displays the home template" do
      user = build(:jd)
      sign_in user
      get root_path
      expect(response).to render_template("home")
    end
  end
end
