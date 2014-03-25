class Category < ActiveRecord::Base
	has_many :products
	
	acts_as_list :scope => :parent_id
  acts_as_tree :order => "position"
end
