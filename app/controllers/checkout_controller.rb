class CheckoutController < ApplicationController
  def new
  end

  def index
    @cart = session[:cart] || {}
    @products = Product.where(id: @cart.keys)

    @subtotal = @products.sum do |product|
      product.price * @cart[product.id.to_s]
    end

    # default MB tax
    @tax_rate = 0.12
    @taxes = @subtotal * @tax_rate
    @total = @subtotal + @taxes
  end

  def create
    cart = session[:cart] || {}
    products = Product.find(cart.keys)

    province = Province.find(params[:province_id])

    subtotal = products.sum do |product|
      product.price * cart[product.id.to_s]
    end

    hst = subtotal * province.hst_rate
    pst = subtotal * province.pst_rate
    gst = subtotal * province.gst_rate

    total = subtotal + hst + pst + gst

    customer = Customer.create!(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      street: params[:street],
      city: params[:city],
      province_id: params[:province_id]
    )

    order = Order.create!(
      customer: customer,
      subtotal: subtotal,
      hst_amount: hst,
      pst_amount: pst,
      gst_amount: gst,
      total_amount: total,
      status: "pending"
    )

    products.each do |product|
      qty = cart[product.id.to_s]

      OrderItem.create!(
        order: order,
        product: product,
        quantity: qty,
        price_at_purchase: product.price,
        line_total: product.price * qty
      )
    end

    session[:cart] = {}

    redirect_to root_path, notice: "Order placed successfully!"
  end
end
