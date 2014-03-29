require 'json'

class OrderController < ApplicationController
	def new
		@order = Order.new
	end

	def create
		@order = Order.new(order_params)

    respond_to do |format|
      if @order.save
      	items = JSON.parse params[:cartfield]
      	items.each{ |i|
      		@order_item = OrderItem.new({
      			order_id: @order.id,
      			product_id: i['i'],
      			quantity: i['c'],
      			price: i['p']
      		})
      		@order_item.save
      	}
        format.html {
        	redirect_to index_path
        }
      else
        format.html {redirect_to index_path, notice: 'Order wasn\'t successfully created.'}
      end
    end
	end

private
  def order_params
    params.require(:order).permit(
    	:first_name,
			:middle_name,
			:last_name,
			:gender,
			:phone,
			:email,
			:pay_type,
			:addr_street,
			:addr_home,
			:addr_block,
			:addr_flat,
			:comment
    )
  end
end
