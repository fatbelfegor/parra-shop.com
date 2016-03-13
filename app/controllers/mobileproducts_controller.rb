class MobileproductsController < ApplicationController
  
  def index
    @products = Product.joins(:categories).where("categories.isMobile = true").distinct
    
    # respond_to do |format|
#         format.html { render :index }
#         format.json { render :json =>  @categoriesmobile.to_json(:include => [:parent])}
#       end
  end
end
