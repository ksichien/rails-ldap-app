require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /sign_up" do
    it "retrieves the sign up page" do
      get new_user_registration_path
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
    it "renders the new registration template" do
      get new_user_registration_path
      expect(response).to render_template("devise/registrations/new")
    end
  end
end
