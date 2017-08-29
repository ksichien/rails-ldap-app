require 'rails_helper'

RSpec.describe 'LdapUsers', type: :request do
  include Devise::Test::IntegrationHelpers
  describe 'GET /add before log in' do
    it 'redirects to new user session path' do
      get add_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /add after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the add path' do
      get add_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the add template' do
      get add_path
      expect(response).to render_template('add')
    end
  end
  describe 'GET /add_multiple before log in' do
    it 'redirects to new user session path' do
      get add_multiple_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /add_multiple after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the add_multiple path' do
      get add_multiple_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the add_multiple template' do
      get add_multiple_path
      expect(response).to render_template('add_multiple')
    end
  end
  describe 'GET /create before log in' do
    it 'redirects to new user session path' do
      get create_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /create after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the create path' do
      get create_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the new template' do
      get create_path
      expect(response).to render_template('new')
    end
  end
  describe 'GET /create_group before log in' do
    it 'redirects to new user session path' do
      get create_group_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /create_group after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the create_group path' do
      get create_group_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the new_group template' do
      get create_group_path
      expect(response).to render_template('new_group')
    end
  end
  describe 'GET /destroy' do
    it 'redirects to new user session path' do
      get destroy_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /destroy after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the destroy path' do
      get destroy_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the delete template' do
      get destroy_path
      expect(response).to render_template('delete')
    end
  end
  describe 'GET /destroy_group before log in' do
    it 'redirects to new user session path' do
      get destroy_group_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /destroy_group after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the destroy_group path' do
      get destroy_group_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the delete_group template' do
      get destroy_group_path
      expect(response).to render_template('delete_group')
    end
  end
  describe 'GET /remove before log in' do
    it 'redirects to new user session path' do
      get remove_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /remove after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the remove path' do
      get remove_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the remove template' do
      get remove_path
      expect(response).to render_template('remove')
    end
  end
  describe 'GET /remove_multiple before log in' do
    it 'redirects to new user session path' do
      get remove_multiple_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /remove_multiple after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the remove_multiple path' do
      get remove_multiple_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the remove_multiple template' do
      get remove_multiple_path
      expect(response).to render_template('remove_multiple')
    end
  end
  describe 'GET /result before log in' do
    it 'redirects to new user session path' do
      get result_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /result after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the result path' do
      get result_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the result template' do
      get result_path
      expect(response).to render_template('result')
    end
  end
  describe 'GET /update before log in' do
    it 'redirects to new user session path' do
      get update_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /update after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the update path' do
      get update_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the edit template' do
      get update_path
      expect(response).to render_template('edit')
    end
  end
  describe 'GET /search before log in' do
    it 'redirects to new user session path' do
      get search_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /search after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the search path' do
      get search_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the search template' do
      get search_path
      expect(response).to render_template('search')
    end
  end
  describe 'GET /search_group before log in' do
    it 'redirects to new user session path' do
      get search_group_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe 'GET /search_group after log in' do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it 'retrieves the search_group path' do
      get search_group_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it 'renders the search_group template' do
      get search_group_path
      expect(response).to render_template('search_group')
    end
  end
end
