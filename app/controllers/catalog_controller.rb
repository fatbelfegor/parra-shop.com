#!/bin/env ruby
# encoding: utf-8

class CatalogController < ApplicationController
  def index
    if params[:category_scode].present?
      @category = Category.find_by_scode(params[:category_scode])
      unless @category.url.blank?
        redirect_to "/catalog/#{@category.url}"
      end
      @title = @category.seo_title
      @seo_description = @category.seo_description
      @seo_keywords = @category.seo_keywords
      return render :action => 'page404' unless @category
    elsif params[:q].present?
      @title = "Поиск: #{params[:q]}"
      @products = Product.where('invisible = false')
    elsif params[:url].present?
      @category = Category.find_by url: params[:url]
      params[:category_scode] = @category.scode
      @title = @category.seo_title
      @seo_description = @category.seo_description
      @seo_keywords = @category.seo_keywords
    end
  end

  def products
    if params[:limit].present?
      limit = params[:limit].to_i
    else
      limit = 18
    end
    if params[:offset].present?
      offset = params[:offset].to_i
    else
      offset = 0
    end
    if params[:cat_id].present?
      if user_signed_in? && current_user.admin?
        invisible = {}
      else
        invisible = {invisible: false}
      end
      products = Category.find(params[:cat_id]).products.where(invisible).limit(limit).offset(offset)
    elsif params[:q].present?
      products = Product.search({query: {multi_match: {query: params[:q], fields: [:name, :scode]}}}, from: params[:offset], size: params[:limit]).records
    end
    ret = []
    for p in products
      sizes = p.sizes
      if sizes[0]
        colors = sizes[0].colors
        if colors[0]
          textures = colors[0].textures
        else
          textures = []
        end
        options = sizes[0].options
      else
        colors = textures = options = []
      end
      ret << {product: p, images: p.images, sizes: sizes, colors: colors, textures: textures, options: options, extension: p.extension}
    end
    render json: ret
  end

  def product
    @product = Product.find_by_scode(params[:scode])
    return render :action => 'page404' unless @product
    unless @product.seo_title.blank?
      @title = @product.seo_title
    else
      @title = @product.name
    end
    @seo_description = @product.seo_description
    @seo_keywords = @product.seo_keywords
    if @product.category
      @title = @product.category.seo_title + " - " + @title
    else
      @title = @product.subcategory.name + " - " + @title
    end
    if @product.invisible and (!user_signed_in? || !current_user.admin?)
      render :action => 'page404'
    end    
  end
end