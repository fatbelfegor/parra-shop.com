class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  rescue_from Exception, with: :page404

  def page404
  end
  
  protected
  
   def configure_permitted_parameters
       devise_parameter_sanitizer.for(:sign_up) << :admin
   end

  def admin_required
    unless user_signed_in? && current_user.admin?
      redirect_to "/"
      false
    end
    true
  end

  def manager_required
    unless user_signed_in? && (current_user.admin? || current_user.manager)
      redirect_to "/"
      false
    end
    true
  end
end
