class Product < ActiveRecord::Base
	# include Elasticsearch::Model
	# include Elasticsearch::Model::Callbacks

	belongs_to :category
	belongs_to :subcategory
	belongs_to :extension
	belongs_to :color_category
	belongs_to :stock
	has_many :product_images
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
	# 	indexes :category_id
	# 	indexes :name
	# 	indexes :scode
	# 	indexes :position
	# 	indexes :invisible
	# end

	def old_price
		if $global_share
			if self[:old_price] == 0
				self[:price]
			else
				self[:old_price]
			end
		else
			self[:old_price]
		end
	end

	def price
		if $global_share# and self[:old_price] == 0
			self[:price] * ( 1 - $global_discount / 100.0 )
		else
			self[:price]
		end
	end

end