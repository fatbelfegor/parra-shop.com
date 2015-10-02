#!/bin/env ruby
# encoding: utf-8

class PrcolorsController < ApplicationController
	def new
		@prcolor = Prsize.find(params[:id]).prcolors.new
    @prsizes = Prsize.all
	end

  def copy
    @categories = Category.roots
    @prcolor = Prcolor.new
    @prsizes = Prsize.all
  end

	def create
    if params[:copy_size].present?
      prsize = Prsize.find params[:id]
      scode = prsize.product.scode
      for p in Prsize.find(params[:copy_size]).prcolors
        prcolor = prsize.prcolors.create scode: scode+'_'+p.scode.split('_').last, name: p.name, price: p.price, description: p.description, images: p.images
        for t in p.textures
          prcolor.textures.create name: t[:name], scode: t[:scode], price: t[:price], image: t[:image]
        end
      end
    elsif params[:copy_id].present?
      prsize = Prsize.find prcolor_params[:prsize_id]
      scode = prsize.product.scode
      for p in Prsize.find(params[:copy_id]).prcolors
        prcolor = prsize.prcolors.create scode: scode+'_'+p.scode.split('_').last, name: p.name, price: p.price, description: p.description, image: p.image
        for t in p.textures
          prcolor.textures.create name: t[:name], scode: t[:scode], price: t[:price], image: t[:image]
        end
      end
    else
      prcolor = Prcolor.create prcolor_params
      if params[:textures]
        for t in params[:textures]
          prcolor.textures.create name: t[:name], scode: t[:scode], price: t[:price], image: t[:image]
        end
      end
      scode = prcolor.prsize.product.scode
    end
    redirect_to URI.encode "/kupit/#{prcolor.prsize.product.scode}"
  end

  def edit
    @prcolor = Prcolor.find params[:id]
    @prsizes = Prsize.all
  end

  def update
    prcolor = Prcolor.find(params[:id])
    prcolor.update prcolor_params
    prcolor.textures.destroy_all if prcolor.textures
    if params[:textures]
      for t in params[:textures]
        prcolor.textures.create name: t[:name], scode: t[:scode], price: t[:price], image: t[:image]
      end
    end
    redirect_to URI.encode "/kupit/#{prcolor.prsize.product.scode}"
  end

  def destroy
    prcolor = Prcolor.find(params[:id]).destroy
    redirect_to URI.encode "/kupit/#{prcolor.prsize.product.scode}"
  end

private
  def prcolor_params
    params.require(:prcolor).permit(
    	:prsize_id,
			:scode,
      :images,
      :name,
      :description,
			:price
    )
  end
end
