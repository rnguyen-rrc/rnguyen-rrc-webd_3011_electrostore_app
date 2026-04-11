class OrdersController < ApplicationController
  def index
    if current_user
      @orders = current_user.orders.includes(:order_items, :user).order(created_at: :desc)
    else
      redirect_to login_path, alert: "Please login to view your orders"
    end
  end
  
  def show
    @order = Order.find(params[:id])
  end
end