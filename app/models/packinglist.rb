class Packinglist < ActiveRecord::Base
	has_many :packinglistitems, dependent: :destroy
end