require 'rails_helper'

RSpec.describe "LdapUsers", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /add before log in" do
    it "redirects to users sign in page" do
      get add_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /add after log in" do
    before(:each) do
      user = build(:jd)
      sign_in user
    end
    it "retrieves the add page" do
      get add_path
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
    it "renders the add template" do
      get add_path
      expect(response).to render_template("add")
    end
  end
  describe "GET /add_multiple" do
    it "redirects to users sign in page" do
      get add_multiple_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /create" do
    it "redirects to users sign in page" do
      get create_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /destroy" do
    it "redirects to users sign in page" do
      get destroy_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /destroy_group" do
    it "redirects to users sign in page" do
      get destroy_group_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /remove" do
    it "redirects to users sign in page" do
      get remove_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /remove_multiple" do
    it "redirects to users sign in page" do
      get remove_multiple_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /result" do
    it "redirects to users sign in page" do
      get result_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /update" do
    it "redirects to users sign in page" do
      get update_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /search" do
    it "redirects to users sign in page" do
      get search_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
  describe "GET /search_group" do
    it "redirects to users sign in page" do
      get search_group_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end
end
