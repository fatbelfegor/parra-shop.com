class MobileproductsController < ApplicationController
  
  def index
    @products = Product.joins(:categories).where "categories.isMobile = true"
    
    # respond_to do |format|
#         format.html { render :index }
#         format.json { render :json =>  @categoriesmobile.to_json(:include => [:parent])}
#       end
  end
end
