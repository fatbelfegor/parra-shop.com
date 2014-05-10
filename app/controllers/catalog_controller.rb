#!/bin/env ruby
# encoding: utf-8

class CatalogController < ApplicationController
  def index
    @category = Category.find_by_scode('bella')
    #@title = @category.s_title
    if @category
      @products = @category.products
    else
      logger.error("Попытка доступа к несуществующей категории #{params[:category_id]}")
      redirect_to_index("Неверный идентификатор категории")
    end
  end
end
