class Packinglistitem < ActiveRecord::Base
	belongs_to :packinglist
	belongs_to :product
end