class OrderItem < ActiveRecord::Base
	belongs_to :product
	
	def total_price
    self.price * self.quantity
  end
end
