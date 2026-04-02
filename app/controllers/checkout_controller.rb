class CheckoutController < ApplicationController
  def new
    if current_user
      @user = current_user
    end

    @cart = session[:cart] || {}
    @products = Product.where(id: @cart.keys)

    @subtotal = @products.sum do |product|
      product.price * @cart[product.id.to_s]
    end

    # Default Manitoba tax (12%)
    tax_rate = 0.12
    @taxes = @subtotal * tax_rate

    @total = @subtotal + @taxes
  end

  def index
  if current_user
    redirect_to new_checkout_path
    return
  end

  # Guest checkout page
  @cart = session[:cart] || {}
  @products = Product.where(id: @cart.keys)

  @subtotal = @products.sum do |product|
    product.price * @cart[product.id.to_s]
  end

  @tax_rate = 0.12
  @taxes = @subtotal * @tax_rate
  @total = @subtotal + @taxes
  end

  def create
  # 1. Get cart
  cart = session[:cart] || {}
  products = Product.where(id: cart.keys)

  # 2. Calculate subtotal
  subtotal = products.sum do |product|
    product.price * cart[product.id.to_s]
  end

  # 3. Get province
  province =
    if current_user&.province.present?
      current_user.province
    elsif params[:province_id].present?
      Province.find(params[:province_id])
    else
      nil
    end

  # Prevent proceeding without province
  unless province
    redirect_to checkout_path, alert: "Please select a province"
    return
  end

  # 4. Tax calculation
  hst_rate = province.hst_rate
  pst_rate = province.pst_rate

  hst_amount = subtotal * hst_rate
  pst_amount = subtotal * pst_rate
  total = subtotal + hst_amount + pst_amount

  # 5. Create order
  order = Order.create!(
    user_id: current_user&.id,
    first_name: params[:first_name],
    last_name: params[:last_name],
    shipping_street: params[:street],
    shipping_city: params[:city],
    shipping_province_id: province.id,
    shipping_postal_code: params[:postal_code],
    subtotal: subtotal,
    hst_amount: hst_amount,
    pst_amount: pst_amount,
    total_amount: total,
    status: "pending",
    email: params[:email],
    phone: params[:phone],
  )

  # 6. Create order items
  products.each do |product|
    quantity = cart[product.id.to_s]

    OrderItem.create!(
      order_id: order.id, 
      product_id: product.id,
      quantity: quantity,
      price_at_purchase: product.price,
      subtotal: product.price * quantity,
      hst_rate: hst_rate,
      pst_rate: pst_rate,
      hst_amount: product.price * quantity * hst_rate,
      pst_amount: product.price * quantity * pst_rate,
      line_total: product.price * quantity * (1 + hst_rate + pst_rate)
    )
  end

  # 7. Clear cart
  session[:cart] = {}

  # 8. Redirect
  redirect_to order_path(order), notice: "Order placed successfully!"
  end
end
