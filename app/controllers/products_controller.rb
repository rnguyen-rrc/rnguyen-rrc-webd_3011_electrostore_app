class ProductsController < ApplicationController
  def index
    @products = Product.includes(:categories).order(created_at: :desc)
  end

  def show
    @product = Product.find(params[:id])
  end
end