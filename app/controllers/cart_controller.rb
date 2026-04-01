class CartController < ApplicationController
  def index
    @cart = session[:cart] || {}

    @products = Product.where(id: @cart.keys)

    # remove invalid product IDs from session
    valid_ids = @products.pluck(:id).map(&:to_s)
    session[:cart].slice!(*valid_ids)

    @subtotal = @products.sum do |product|
      product.price * @cart[product.id.to_s]
    end

    @tax_rate = 0.12 # Manitoba (5% GST + 7% PST)

    @taxes = @subtotal * @tax_rate
    @total = @subtotal + @taxes
  end

  def add
    session[:cart] ||= {}

    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i

    quantity = 1 if quantity <= 0  # safety

    session[:cart][product_id] ||= 0
    session[:cart][product_id] += quantity

    redirect_to product_path(product_id), notice: "Added to cart"
  end

  def update
    product_id = params[:product_id].to_s
    quantity   = params[:quantity].to_i

    session[:cart] ||= {}

    if quantity > 0
      session[:cart][product_id] = quantity
    else
      session[:cart].delete(product_id)
    end

    redirect_to cart_path, notice: "Cart updated"
  end

  def remove
    product_id = params[:product_id].to_s

    session[:cart]&.delete(product_id)

    redirect_to cart_path, notice: "Item removed from cart"
  end
end