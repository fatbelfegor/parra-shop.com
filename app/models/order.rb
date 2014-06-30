class Order < ActiveRecord::Base
	has_many :order_items ,:dependent => :destroy
	
	def total_price
    sum = 0
    if(order_items)
      order_items.each do |item|
        sum += item.total_price
      end
    end
    sum
  end
end
