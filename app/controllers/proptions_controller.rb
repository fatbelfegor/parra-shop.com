class ProptionsController < ApplicationController
	def new
		@proption = Proption.new
		@products = Product.all
		@product_id = params[:product_id]
      
		if params[:product_id]
      @proption.product = Product.find(params[:product_id])
    end		
	end

	def create
    @proption = Proption.new(proption_params)

    @proption.save
    redirect_to '/kupit/'+@proption.product.name
  end

private
  def proption_params
    params.require(:proption).permit(
    	:product_id,
			:scode,
			:name,
			:price
    )
  end
end
