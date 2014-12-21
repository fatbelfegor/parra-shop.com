class PrsizesController < ApplicationController
	def new
		@prsize = Prsize.new product_id: params[:id]
		@products = Product.all
	end

	def create
    @prsize = Prsize.create prsize_params
    redirect_to URI.encode '/kupit/'+@prsize.product.scode
  end

  def edit
    @prsize = Prsize.find(params[:id])
    @products = Product.all
  end

  def update
    @prsize = Prsize.find(params[:id])
    @prsize.update prsize_params
    redirect_to URI.encode '/kupit/'+@prsize.product.scode
  end

  def destroy
    @prsize = Prsize.find(params[:id])
    @prsize.destroy
    redirect_to URI.encode '/kupit/'+@prsize.product.scode
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
