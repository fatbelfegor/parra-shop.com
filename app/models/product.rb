class Product < ActiveRecord::Base
	belongs_to :category
	has_many :order_items
	#has_and_belongs_to_many :categories
	acts_as_list :scope => :category

	has_many :prsizes, :dependent => :destroy
	has_many :prcolors, :dependent => :destroy
	has_many :proptions, :dependent => :destroy
	
	validates :name, :scode, presence: true
	validates :scode, uniqueness: true
	
	validates :price, numericality: {greater_than_or_equal_to: 0.01}

end
