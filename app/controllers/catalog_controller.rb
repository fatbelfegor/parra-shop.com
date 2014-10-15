#!/bin/env ruby
# encoding: utf-8

class CatalogController < ApplicationController
  def index
    session[:proption] = nil
    session[:prsize] = nil
    session[:color] = nil
    
    @category = Category.find_by_scode(params[:category_scode])
    @title = @category.title
    return render :action => 'page404' unless @category
    if(@category)
      if user_signed_in? && current_user.admin?
        @products = @category.products          
      else
        @products = @category.products.where('invisible = false')
      end
    end
  end
end