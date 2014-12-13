#!/bin/env ruby
# encoding: utf-8

class CatalogController < ApplicationController
  def index
    if params[:category_scode].present?
      @category = Category.find_by_scode(params[:category_scode])
      unless @category.url.blank?
        redirect_to "/catalog/#{@category.url}"
      end
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
      return render :action => 'page404' unless @category
    elsif params[:q].present?
      @title = "Поиск: #{params[:q]}"
      @products = Product.where('invisible = false')
    elsif params[:url].present?
      @category = Category.find_by url: params[:url]
      params[:category_scode] = @category.scode
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
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
      prcolors = p.prcolors
      if prcolors[0]
        textures = prcolors[0]
      else
        textures = []
      end
      ret << {product: p, prsizes: p.prsizes, prcolors: prcolors, textures: textures, proptions: p.proptions}
    end
    render json: ret
  end
end