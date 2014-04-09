class Category < ActiveRecord::Base
	has_many :products
	acts_as_list :scope => :parent_id
  acts_as_tree :order => "position"
  has_and_belongs_to_many :products, :order => "position ASC"
  
  validates :name, presence: true
end
