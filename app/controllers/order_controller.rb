class OrderController < ApplicationController
    def create
		@order = Order.new(order_params)

        respond_to do |format|
            if params[:cartfield] and @order.save
            	items = JSON.parse params[:cartfield]
            	items.each{ |i|
            		@order.order_items.create({
            			product_id: i['i'],
            			quantity: i['c'],
            			price: i['p'].sub(' ', ''),
                        size: i['s'],
                        color: i['l'],
                        option: i['o'],
                        size_scode: i['ss'],
                        color_scode: i['ls'],
                        option_scode: i['os']
            		})
            	}
                if user_signed_in? && (current_user.admin? || current_user.manager)
                    format.html{redirect_to "/orders/#{@order.id}/edit"}
                else
                    OrderMailer.ordersave(@order).deliver
                    OrderMailer.ordersaveclient(@order).deliver
                    format.html{redirect_to index_path, notice: 'ordersave'}
                end
            else
                format.html{redirect_to index_path, notice: 'Заказ не был оформлен.'}
            end
        end
	end
end