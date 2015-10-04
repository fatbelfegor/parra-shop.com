require 'elasticsearch/model'

class Product < ActiveRecord::Base
	# include Elasticsearch::Model
	# include Elasticsearch::Model::Callbacks

	belongs_to :category
	belongs_to :subcategory
	belongs_to :extension
	has_many :order_items
	has_many :product_footer_images
	has_and_belongs_to_many :categories, :autosave => true
	#has_and_belongs_to_many :categories , :join_table => :categories_products , :autosave => true
	acts_as_list :scope => :category

	has_many :prsizes, :dependent => :destroy
	has_many :prcolors, :dependent => :destroy
	has_many :proptions, :dependent => :destroy
	
	validates :name, :scode, presence: true
	validates :scode, uniqueness: true
	validates :price, numericality: {greater_than_or_equal_to: 0.01}

	# mappings dynamic: false do
	# 	indexes :name
	# 	indexes :scode
	# end

end
