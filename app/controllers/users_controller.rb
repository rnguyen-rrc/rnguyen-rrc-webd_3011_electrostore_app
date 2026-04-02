class UsersController < ApplicationController
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
end