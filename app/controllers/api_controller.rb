class ApiController < ApplicationController

	def filter_list
		column = params[:column]
		render nothing: true, status: 405 if column != 'color' and column != 'texture'
		render json: get_products.where.not(column => nil, column => '')
			.order(column).pluck("DISTINCT #{column}").to_json
	end

	def filter_range
		column = params[:column]
		render nothing: true, status: 405 if column != 'length' and column != 'width' and column != 'height'
		render json: get_products.where.not(column => nil)
			.order(column).select("min(#{column}) min, max(#{column}) max").take.to_json
	end

	def filter_get
		if params[:color] == 'true'
			order = :color_position
		else
			order = :position
		end
		where = {}
		[:color, :texture].each do |column|
			param = JSON.parse(params[column])
			where[column] = param if param.any?
		end
		[:length, :width, :height].each do |column|
			param = JSON.parse(params[column])
			where[column] = (param[0]..param[1]) if param.any?
		end

		render partial: 'pages/product', collection: get_products.where(where).order(order)
	end

private

	def get_products
		if params[:color] == 'true'
			join = :color_category
			where = :color_categories
		else
			join = :categories
			where = :categories
		end
		Product.joins(join).where(where => {id: params[:id]})
	end

end