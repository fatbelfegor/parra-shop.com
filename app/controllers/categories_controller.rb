#!/bin/env ruby
# encoding: utf-8

class CategoriesController < ApplicationController
	def new
		@categories = Category.all
	end

	def create
		@category = Category.new(category_params)
 
		@category.save
		render text: 'Сохранилось'
	end

	def catalog
		@category = Category.find_by(scode: params[:scode])
		@products = @category.products
		render "main/index"		
	end

private
	def category_params
		params.require(:category).permit(
			:name,
			:description,
			:position,
			:header,
			:images,
			:parent_id,
			:s_title,
			:s_description,
			:s_keyword,
			:s_name,
			:scode,
			:commission,
			:rate
		)
	end
end
