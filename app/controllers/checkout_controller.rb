class CheckoutController < ApplicationController
  # ------------------------
  # CHECKOUT PAGE
  # ------------------------
  def new
    @user = current_user if current_user

    @cart = session[:cart] || {}
    @products = Product.where(id: @cart.keys)

    @subtotal = @products.sum do |product|
      product.price * @cart[product.id.to_s]
    end

    tax_rate = 0.12
    @taxes = @subtotal * tax_rate
    @total = @subtotal + @taxes
  end

  # ------------------------
  # GUEST CHECKOUT PAGE
  # ------------------------
  def index
    if current_user
      redirect_to new_checkout_path
      return
    end

    @cart = session[:cart] || {}
    @products = Product.where(id: @cart.keys)

    @subtotal = @products.sum do |product|
      product.price * @cart[product.id.to_s]
    end

    @tax_rate = 0.12
    @taxes = @subtotal * @tax_rate
    @total = @subtotal + @taxes
  end

  # ------------------------
  # CREATE ORDER + STRIPE SESSION
  # ------------------------
  def create
  # ------------------------
  # IF ORDER ALREADY EXISTS (Pay Now flow)
  # ------------------------
  if params[:order_id].present?
    order = Order.find(params[:order_id])

    cart = session[:cart] || {}
    products = Product.where(id: cart.keys)

  else
    # ------------------------
    # NORMAL CHECKOUT (create order)
    # ------------------------
    cart = session[:cart] || {}
    products = Product.where(id: cart.keys)

    subtotal = products.sum do |product|
      product.price * cart[product.id.to_s]
    end

    province =
      if current_user&.province.present?
        current_user.province
      elsif params[:province_id].present?
        Province.find(params[:province_id])
      end

    unless province
      redirect_to checkout_path, alert: "Please select a province"
      return
    end

    hst_rate = province.hst_rate
    pst_rate = province.pst_rate

    hst_amount = subtotal * hst_rate
    pst_amount = subtotal * pst_rate
    total = subtotal + hst_amount + pst_amount

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

    products.each do |product|
      quantity = cart[product.id.to_s]

      OrderItem.create!(
        order: order,
        product: product,
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
  end

  # ------------------------
  # STRIPE SESSION
  # ------------------------
  stripe_session = Stripe::Checkout::Session.create(
    payment_method_types: ['card'],
    mode: 'payment',
    line_items: [
      # PRODUCTS
      *order.order_items.map do |item|
        {
          price_data: {
            currency: 'cad',
            product_data: {
              name: item.product.name
            },
            unit_amount: (item.price_at_purchase * 100).to_i
          },
          quantity: item.quantity
        }
      end,

      # HST LINE
      {
        price_data: {
          currency: 'cad',
          product_data: {
            name: "HST / GST"
          },
          unit_amount: (order.hst_amount * 100).to_i
        },
        quantity: 1
      },

      # PST LINE
      {
        price_data: {
          currency: 'cad',
          product_data: {
            name: "PST"
          },
          unit_amount: (order.pst_amount * 100).to_i
        },
        quantity: 1
      }
    ],
    success_url: "#{request.base_url}/checkout/success?order_id=#{order.id}&session_id={CHECKOUT_SESSION_ID}",
    cancel_url: "#{request.base_url}/checkout/cancel",
    metadata: {
      order_id: order.id
    }
  )

  redirect_to stripe_session.url, allow_other_host: true
end

  # ------------------------
  # PAYMENT SUCCESS
  # ------------------------
  def success
    order = Order.find(params[:order_id])

    stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])

    # VERIFY payment from Stripe
    if stripe_session.payment_status == "paid"
      order.update(status: "paid")

      Payment.create!(
        order: order,
        stripe_payment_id: stripe_session.payment_intent,
        payment_method: "card",
        status: "paid",
        payment_date_time: Time.current
      )

      session[:cart] = {}

      redirect_to order_path(order), notice: "Payment successful!"
    else
      redirect_to order_path(order), alert: "Payment not completed."
    end
  end

  # ------------------------
  # PAYMENT CANCEL
  # ------------------------
  def cancel
    redirect_to checkout_path, alert: "Payment cancelled."
  end
end