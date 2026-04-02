class UsersController < ApplicationController

  # Create account AFTER checkout
  def signup_from_order
    order = Order.find(params[:order_id])

    user = User.create!(
      username: params[:username],
      password: params[:password],
      password_confirmation: params[:password_confirmation],

      first_name: order.first_name,
      last_name: order.last_name,

      email: order.email,
      phone: order.phone,

      street_name: order.shipping_street,
      city: order.shipping_city,
      postal_code: order.shipping_postal_code,
      province_id: order.shipping_province_id,

      role: "user"
    )

    order.update(user: user)

    redirect_to root_path, notice: "Account created successfully!"
  end

  # Normal signup page
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = "user"

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully"
    else
      render :new
    end
  end

  # Edit profile
  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: "Profile updated successfully"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :username,
      :password,
      :password_confirmation,
      :email,
      :phone,
      :first_name,
      :last_name,
      :street_name,
      :city,
      :province_id,
      :postal_code
    )
  end
end