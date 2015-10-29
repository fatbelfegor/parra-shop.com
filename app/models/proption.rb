class Proption < ActiveRecord::Base
  belongs_to :prsize

  def self.move
  	for option in self.all
  		product = Product.find(option.product_id)
  		unless product.blank?
  			if product.prsizes.blank?
  				prsize_id = product.prsizes.create(name: '100 x 100', scode: '100 x 100', price: 0).id
  			else
  				prsize_id = product.prsizes.first.id
  			end
  			option.update prsize_id: prsize_id
  		end
  	end
  end
end
