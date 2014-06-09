# encoding: utf-8

class MainController < ApplicationController
  def index
    @products = Product.all
    @cat1 = Category.find_by_scode('bella').products.order('created_at asc').limit(5)
    @cat2 = Category.find_by_scode('style').products.order('created_at asc').limit(5)
    @cat3 = Category.find_by_scode('Диваны').products.order('created_at asc').limit(10)
    #@cat3 = Category.find_by_name('Диваны').products.order('created_at asc').limit(10)
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
