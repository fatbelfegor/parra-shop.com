class Subcategory < ActiveRecord::Base
	belongs_to :category
	has_many :sub_cat_images
	has_many :products
end
