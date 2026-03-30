class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.all

    # Keyword search
    if params[:keyword].present?
      keyword = "%#{params[:keyword]}%"
      @products = @products.where("products.name LIKE ? OR products.description LIKE ?", keyword, keyword)
    end

    # Category filter (many-to-many)
    if params[:category_id].present?
      @products = @products.joins(:categories)
                          .where(categories: { id: params[:category_id] })
    end

    # Order + Pagination
    @products = @products
                  .distinct
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(12)
  end

  def show
    @product = Product.find(params[:id])
  end
end