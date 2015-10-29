class OrderItem < ActiveRecord::Base
	belongs_to :product
	belongs_to :order
	
	def total_price
    self.price * self.quantity
  end
end
