require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  include Devise::Test::IntegrationHelpers
  describe 'GET /sign_in before log in' do
    it 'retrieves the new user session path' do
      get new_user_session_path
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
    it 'renders the new user session template' do
      get new_user_session_path
      expect(response).to render_template('devise/sessions/new')
    end
  end
  describe 'GET /sign_in after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'redirects to the root path' do
      get new_user_session_path
      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(302)
    end
  end
end
