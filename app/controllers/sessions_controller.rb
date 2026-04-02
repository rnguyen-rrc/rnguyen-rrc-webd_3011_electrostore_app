class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in!"
    else
      flash[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully"
  end
end