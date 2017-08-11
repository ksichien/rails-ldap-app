require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /sign_in" do
    it "retrieves the sign in page" do
      get new_user_session_path
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
    it "renders the new session template" do
      get new_user_session_path
      expect(response).to render_template("devise/sessions/new")
    end
  end
end
