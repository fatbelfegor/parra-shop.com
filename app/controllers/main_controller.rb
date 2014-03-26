class MainController < ApplicationController
  def index
    @products = Product.all
  end

  def cart  	
  end
end
