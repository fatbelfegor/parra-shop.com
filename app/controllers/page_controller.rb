class PageController < ApplicationController
  def index
    @products = Product.all
  end
  
  def main
    @products = Product.all
  end

  def cart  	
  end
end
