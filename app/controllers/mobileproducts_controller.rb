class MobileproductsController < ApplicationController
  
  def index
    products = Product.select(:id, :category_id, :name, :shortdesk, :description, :price, :position, :updated_at).includes(:product_images).joins(:categories).where("categories.isMobile = true").distinct
    result = []
    for p in products
    	result << {
    		id: p.id,
    		category_id: p.category_id,
    		name: p.name,
    		shortdesk: p.shortdesk,
    		description: p.description,
    		price: p.price,
    		position: p.position,
    		updated_at: p.updated_at,
    		images: p.product_images.select(:image).map{|pi| pi.image.url}.join(',')
    	}
    end
    render json: result

    # respond_to do |format|
#         format.html { render :index }
#         format.json { render :json =>  @categoriesmobile.to_json(:include => [:parent])}
#       end
  end
end
