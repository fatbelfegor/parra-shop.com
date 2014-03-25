class PrcolorsController < ApplicationController
	def new
		@prcolor = Prcolor.new
		@products = Product.all
		@product_id = params[:product_id]
      
		if params[:product_id]
      @prcolor.product = Product.find(params[:product_id])
    end		
	end

	def create
    @prcolor = Prcolor.new(prcolor_params)

    @prcolor.save
    redirect_to '/kupit/'+@prcolor.product.name
  end

  def edit
    @products = Product.all
    @prcolor = Prcolor.find(params[:id])
    @product_id = @prcolor.product_id
  end

  def update
    @prcolor = Prcolor.find(params[:id])

    @prcolor.update_attributes prcolor_params
    redirect_to '/kupit/'+@prcolor.product.name
  end

  def destroy
    @prcolor = Prcolor.find(params[:id])
    @prcolor.destroy
    redirect_to '/kupit/'+@prcolor.product.name
  end

private
  def prcolor_params
    params.require(:prcolor).permit(
    	:product_id,
			:scode,
			:name,
			:price
    )
  end
end
