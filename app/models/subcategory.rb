class Subcategory < ActiveRecord::Base
	belongs_to :category
	has_many :subcategory_items, dependent: :destroy
	has_many :products
end