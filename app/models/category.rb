class Category < ActiveRecord::Base
	belongs_to :category
	has_many :images, as: :imageable
	has_many :categories
	has_many :subcategories
	has_and_belongs_to_many :products
end
