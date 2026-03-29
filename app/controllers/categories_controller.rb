class CategoriesController < ApplicationController
  def index
    @categories = Category
                    .joins(:products)
                    .select("categories.*, COUNT(products.id) AS products_count")
                    .group("categories.id")
                    .order(:name)
    end

  def show
    @category = Category.find(params[:id])
    @products = @category.products
  end
end