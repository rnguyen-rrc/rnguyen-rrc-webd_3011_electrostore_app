class UsersController < ApplicationController
  def signup_from_order
    order = Order.find(params[:order_id])

    user = User.create!(
        username: params[:username],
        email: order.email,
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        province_id: order.shipping_province_id
    )

    order.update(user: user)

    redirect_to root_path, notice: "Account created successfully!"
    end
end