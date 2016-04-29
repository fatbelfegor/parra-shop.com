class Category < ActiveRecord::Base
	# include Elasticsearch::Model
	# include Elasticsearch::Model::Callbacks

	acts_as_list :scope => :parent_id
	acts_as_tree :order => "position"
	has_and_belongs_to_many :products, order: "position ASC", autosave: true
	has_many :subcategories
	has_many :color_categories
  
	validates :name, presence: true

	def title
		self.s_title || 'ParraShop'
	end

	# mappings dynamic: false do
	# 	indexes :name
	# end
end
