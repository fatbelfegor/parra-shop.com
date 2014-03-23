class ProductsController < ApplicationController
	def new
	end

	def create
		@product = Product.new(product_params)
 
	  @product.save
	  redirect_to @product
	end

	def show
	  @product = Product.find(params[:id])
	end

private
  def product_params
    params.require(:products).permit(:title, :text, :images)
  end
end
