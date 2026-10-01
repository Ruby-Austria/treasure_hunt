class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    flash[:alert] = "Too many login attempts. Please try again later."
    redirect_to login_path
  }

  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Welcome back!", status: :see_other
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully", status: :see_other
  end
end
