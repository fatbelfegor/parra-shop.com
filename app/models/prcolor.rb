class Prcolor < ActiveRecord::Base
  belongs_to :prsize
  has_many :textures, dependent: :destroy

  def self.move
  	for color in self.all
  		product = Product.find(color.product_id)
  		unless product.blank?
  			if product.prsizes.blank?
  				prsize_id = product.prsizes.create(name: '100 x 100', scode: '100 x 100', price: 0).id
  			else
  				prsize_id = product.prsizes.first.id
  			end
  			color.update prsize_id: prsize_id
  		end
  	end
  end
end
