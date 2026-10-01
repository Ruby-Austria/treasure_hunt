class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :admin?

  rescue_from StandardError, with: :handle_error

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def require_login
    unless logged_in?
      respond_to do |format|
        format.html { redirect_to login_path, alert: "You must be logged in to access this page." }
        format.json { render json: { error: "Authentication required" }, status: :unauthorized }
      end
    end
  end

  def require_admin
    unless admin?
      redirect_to root_path, alert: "You must be an admin to access this page."
    end
  end

  def handle_error(exception)
    # Log the error to Rollbar with request context
    Rollbar.error(exception, request: request, person: current_user)
    # Re-raise so Rails can handle it normally (show error pages, etc.)
    raise exception
  end
end
