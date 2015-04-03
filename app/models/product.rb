class Product < ActiveRecord::Base
	has_and_belongs_to_many :categories
	has_many :images, as: :imageable
	belongs_to :extension
	belongs_to :category
	belongs_to :subcategory
	has_many :sizes, dependent: :destroy
	validates :scode, uniqueness: true
end