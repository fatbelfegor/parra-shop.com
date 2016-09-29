class TexturesController < ApplicationController
	before_filter :admin_required
	layout 'admin'
	
	def edit
	    @texture = Texture.find(params[:id])
	end

	def update
		@texture = Texture.find(params[:id])

		@texture.update_attributes texture_params
		redirect_to '/kupit/'+@texture.prcolor.product.scode
	end

	def destroy
		@texture = Texture.find(params[:id])
		@texture.destroy
		redirect_to '/kupit/'+@texture.prcolor.product.scode
	end
private
  def texture_params
    params.require(:texture).permit(
		:name,
		:scode,
		:price,
		:image
    )
  end
end