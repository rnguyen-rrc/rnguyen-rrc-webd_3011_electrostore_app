class CheckoutController < ApplicationController
  def new
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
    # 1. Get cart
    cart = session[:cart] || {}
    products = Product.where(id: cart.keys)

    # 2. Calculate subtotal
    subtotal = products.sum do |product|
      product.price * cart[product.id.to_s]
    end

    # 3. Get province + tax
    province = Province.find(params[:province_id])

    hst_rate = province.hst_rate
    pst_rate = province.pst_rate

    hst_amount = subtotal * hst_rate
    pst_amount = subtotal * pst_rate
    total = subtotal + hst_amount + pst_amount

    # 4. Create user (guest as customer)
    user = User.create!(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      phone: params[:phone],
      street_name: params[:street],
      city: params[:city],
      postal_code: params[:postal_code],
      province_id: params[:province_id]
    )

    # 5. Create order
    order = Order.create!(
      user_id: user.id,
      shipping_street: params[:street],
      shipping_city: params[:city],
      shipping_province_id: params[:province_id],
      shipping_postal_code: params[:postal_code],
      subtotal: subtotal,
      hst_amount: hst_amount,
      pst_amount: pst_amount,
      total_amount: total,
      status: "pending"
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

    # 8. Redirect to invoice
    redirect_to order_path(order)
  end
end
