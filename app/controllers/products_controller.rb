class ProductsController < ApplicationController
	def new
		@categories = Category.all
	end

	def create
		@product = Product.new product_params
 
		@product.save
		redirect_to @product
	end

	def buy
		@product = Product.find_by scode: params[:scode]
	end

	def show
		@product = Product.find params[:id]
	end

	def edit
		@categories = Category.all
		@product = Product.find params[:id]
	end

	def destroy
		@product = Product.find(params[:id])
		@product.destroy

		respond_to do |format|
			format.html { redirect_to(@product.category) }
		end
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
