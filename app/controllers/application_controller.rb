class ApplicationController < ActionController::Base
  protect_from_forgery #with: :exception
  helper_method :require_user, :require_admin

  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    Rails.logger.debug("set_csrf_cookie_for_ng called #{form_authenticity_token}")
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def require_user
    Rails.logger.debug("require_user method in application controller")
  	if !user_signed_in?
  		flash[:notice] = "Please sign in!"
  		redirect_to new_user_session_path
  	end
  end

  def is_admin_user
    return false if current_user.nil?
    return current_user.admin?
  end

  def is_any_user
    return false if current_user.nil?
    return user_signed_in?
  end

  def require_admin
    Rails.logger.debug("require_admin method in application controller")
  	unless current_user.admin?
      Rails.logger.debug("NOT an admin")
  		flash[:danger] = "You are not authorized to do that. Contact the commish if you have any questions."
  		redirect_to root_path
  	end
    Rails.logger.debug("Are an admin")
  end

  protected

  def verified_request?
    Rails.logger.debug("verified_request called f_a_t:#{form_authenticity_token}. X-XSRF-TOKEN:#{request.headers['X-XSRF-TOKEN']}")
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end
end
