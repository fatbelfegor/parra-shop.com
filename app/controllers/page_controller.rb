class PageController < ApplicationController
	def index
	@products = Product.all
	if user_signed_in? && current_user.admin?
		@cat1 = Category.find_by_scode('bella').products.order('created_at asc').limit(5)
		@cat2 = Category.find_by_scode('style').products.order('created_at asc').limit(5)
		@cat3 = Category.find_by_scode('Диваны').products.order('created_at asc').limit(10)
	else
		@cat1 = Category.find_by_scode('bella').products.where('invisible = false').order('created_at asc').limit(5)
		@cat2 = Category.find_by_scode('style').products.where('invisible = false').order('created_at asc').limit(5)
		@cat3 = Category.find_by_scode('Диваны').products.where('invisible = false').order('created_at asc').limit(10)
	end
	@banners = Banner.all  
	end
end