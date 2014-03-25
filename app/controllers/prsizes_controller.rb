class PrsizesController < ApplicationController
	def new
		@prsize = Prsize.new
		@products = Product.all
		@product_id = params[:product_id]
      
		if params[:product_id]
      @prsize.product = Product.find(params[:product_id])
    end		
	end

	def create
    @prsize = Prsize.new(prsize_params)

    @prsize.save
    redirect_to '/kupit/'+@prsize.product.name
  end

  def edit
    @products = Product.all
    @prsize = Prsize.find(params[:id])
    @product_id = @prsize.product_id
  end

  def update
    @prsize = Prsize.find(params[:id])

    @prsize.update_attributes prsize_params
    redirect_to '/kupit/'+@prsize.product.name
  end

  def destroy
    @prsize = Prsize.find(params[:id])
    @prsize.destroy
    redirect_to '/kupit/'+@prsize.product.name
  end

private
  def prsize_params
    params.require(:prsize).permit(
    	:product_id,
  		:scode,
  		:name,
  		:price
    )
  end
end
