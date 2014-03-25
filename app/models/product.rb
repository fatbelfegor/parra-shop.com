class Product < ActiveRecord::Base
	belongs_to :category

	has_many :prsizes, :dependent => :destroy
	has_many :prcolors, :dependent => :destroy
	has_many :proptions, :dependent => :destroy
end
