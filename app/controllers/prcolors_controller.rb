#!/bin/env ruby
# encoding: utf-8

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
    unless params[:copy_scode].blank?
      @productScode = Product.find(prcolor_params[:product_id]).scode;
      Product.find_by_scode(params[:copy_scode]).prcolors.each do |p|
        @prcolor = Prcolor.create(product_id: prcolor_params[:product_id], scode: @productScode+'_'+p.scode, name: p.name, price: p.price, description: p.description, images: p.images)
        p.textures.each do |t|
          Texture.create(prcolor_id: @prcolor.id, name: t[:name], scode: t[:scode], price: t[:price], image: t[:image])
        end
      end
    else
      @prcolor = Prcolor.new(prcolor_params)        
      @prcolor.save
      if params[:textures]
        params[:textures].each do |t|
          Texture.create(name: t[:name], scode: t[:scode], price: t[:price], image: t[:image], prcolor_id: @prcolor.id)
        end
      end
    end
    redirect_to controller: :products, action: :show_scode, scode: @prcolor.product.scode
  end

  def edit
    @products = Product.all
    @prcolor = Prcolor.find(params[:id])
    @product_id = @prcolor.product_id
  end

  def update
    @prcolor = Prcolor.find(params[:id])
    @prcolor.update_attributes prcolor_params
      if @prcolor.textures
        @prcolor.textures.destroy_all
      end
      if params[:textures]
        params[:textures].each do |t|
          Texture.create(name: t[:name], scode: t[:scode], price: t[:price], image: t[:image], prcolor_id: @prcolor.id)
      end
    end
    redirect_to controller: :products, action: :show_scode, scode: @prcolor.product.scode
  end

  def destroy
    @prcolor = Prcolor.find(params[:id])
    @prcolor.destroy
    redirect_to controller: :products, action: :show_scode, scode: @prcolor.product.scode
  end

private
  def prcolor_params
    params.require(:prcolor).permit(
    	:product_id,
			:scode,
      :images,
      :name,
      :description,
			:price
    )
  end
end
