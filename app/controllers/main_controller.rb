class MainController < ApplicationController
  def index
    @products = Product.all
    @cat1 = Product.find :all, conditions: {category_id: 1}, limit: 5, order: 'created_at asc'
    @cat2 = Product.find :all, conditions: {category_id: 2}, limit: 5, order: 'created_at asc'
    @cat3 = Product.find :all, limit: 10, order: 'created_at asc'
  end
  
  def main
    @products = Product.all
  end

  def cart  	
  end

  def cartjson
  	@product = Product.find_by_name params[:name]
  	render json: @product
  end
end
