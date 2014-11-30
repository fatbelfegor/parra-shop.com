# encoding: utf-8

class MainController < ApplicationController
  def index
    @banners = Banner.all
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

  def Jimmi
  end  
end
