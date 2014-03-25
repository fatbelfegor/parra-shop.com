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
      redirect_to @prsize.product
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
