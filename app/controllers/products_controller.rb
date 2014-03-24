class ProductsController < ApplicationController
	def new
		@categories = Category.all
	end

	def create
		@product = Product.new(product_params)
 
		@product.save
		redirect_to @product
	end

	def buy
		@product = Product.find_by(scode: params[:scode])
	end

	def show
	  @product = Product.find(params[:id])
	end

private
  def product_params
    params.require(:product).permit(
    	:category_id,
		:scode,
		:name,
		:description,
		:images,
		:price,
		:shortdesk,
		:delemiter,
		:invisible,
		:main,
		:action,
		:best,
		:position,
		:s_title,
		:s_description,
		:s_keyword,
		:s_imagealt
    )
  end
end
