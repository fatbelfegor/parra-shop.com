class Category < ActiveRecord::Base
	acts_as_list :scope => :parent_id
	acts_as_tree :order => "position"
	has_and_belongs_to_many :products, order: "position ASC", autosave: true
  
	validates :name, presence: true

	def title
		self.s_title || 'ParraShop'
	end
end
