class MainController < ApplicationController
  def index
    
  end
  
  def main
    @products = Product.all
  end
  
  
end
