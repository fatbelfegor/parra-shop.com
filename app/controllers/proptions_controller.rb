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
    redirect_to URI.encode("/kupit/#{@proption.product.scode}")
  end

  def edit
    @products = Product.all
    @proption = Proption.find(params[:id])
    @product_id = @proption.product_id
  end

  def update
    @proption = Proption.find(params[:id])

    @proption.update_attributes proption_params
    redirect_to URI.encode("/kupit/#{@proption.product.scode}")
  end

  def destroy
    @proption = Proption.find(params[:id])
    @proption.destroy
    redirect_to URI.encode("/kupit/#{@proption.product.scode}")
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
