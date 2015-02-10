class Product < ActiveRecord::Base
	has_and_belongs_to_many :categories
	has_many :images, as: :imageable
	validates :scode, uniqueness: true
end