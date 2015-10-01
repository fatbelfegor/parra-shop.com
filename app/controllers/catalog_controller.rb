#!/bin/env ruby
# encoding: utf-8

class CatalogController < ApplicationController
  # rescue_from Exception, with: :not_found

  def not_found
    render 'pages/not_found', status: 404
  end
  def index
    if 
      invisible = {}
    else
      invisible = {}
    end
    if params[:category_scode].present?
      @category = Category.find_by_scode(params[:category_scode])
      fresh_when @category
      return render 'application/page404' if @category.blank?
      unless @category.url.blank?
        redirect_to "/catalog/#{@category.url}", status: 301
      end
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
      return render :action => 'page404' unless @category
      if @category.subcategories.empty?
        @products = @category.products.where(invisible)
        @products = @products.where(invisible: false) unless user_signed_in? && current_user.admin? 
      end
    elsif params[:q].present?
      @title = "Поиск: #{params[:q]}"
      @products = Product.search({query: {multi_match: {query: params[:q], fields: [:name, :scode]}}}).records
    elsif params[:url].present?
      @category = Category.find_by url: params[:url]
      fresh_when @category
      params[:category_scode] = @category.scode
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
      if @category.subcategories.empty?
        @products = @category.products.where(invisible)
      end
    end
  end
end