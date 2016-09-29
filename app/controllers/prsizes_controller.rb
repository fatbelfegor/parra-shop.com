class PrsizesController < ApplicationController
  before_filter :admin_required
  layout 'admin'
  
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

  def copy_sizes
    product_id = params[:to].to_i
    for size in Product.find(params[:from]).prsizes
      new_size = size.dup
      new_size.product_id = product_id
      new_size.save
      size_id = new_size.id
      for color in size.prcolors
        new_color = color.dup
        new_color.prsize_id = size_id
        new_color.save
        color_id = new_color.id
        for texture in color.textures
          new_texture = texture.dup
          new_texture.prcolor_id = color_id
          new_texture.save
        end
      end
      for option in size.proptions
        new_option = option.dup
        new_option.prsize_id = size_id
        new_option.save
      end
    end
    redirect_to :back
  end
  def copy_size
    product_id = params[:to].to_i
    size = Prsize.find params[:from]
    new_size = size.dup
    new_size.product_id = product_id
    new_size.save
    size_id = new_size.id
    for color in size.prcolors
      new_color = color.dup
      new_color.prsize_id = size_id
      new_color.save
      color_id = new_color.id
      for texture in color.textures
        new_texture = texture.dup
        new_texture.prcolor_id = color_id
        new_texture.save
      end
    end
    for option in size.proptions
      new_option = option.dup
      new_option.prsize_id = size_id
      new_option.save
    end
    redirect_to :back
  end

private
  def prsize_params
    params.require(:prsize).permit(
    	:product_id,
  		:scode,
  		:name,
      :old_price,
  		:price
    )
  end
end
