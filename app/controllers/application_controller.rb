class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :retrieve_ldap_username

  def retrieve_ldap_username
    if user_signed_in?
      current_user.username.gsub!("@#{Figaro.env.domain}",'')
    end
  end

  protected

  def configure_permitted_parameters
    # devise 4.3 .for method replaced by .permit
    # devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end
