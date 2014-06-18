class OrderItemController < ApplicationController
	before_filter :admin_required

  def plus
  	item = OrderItem.find(params[:id])
  	item.quantity += 1
  	item.save()
  	render nothing: true
  end

  def minus
  	item = OrderItem.find(params[:id])
  	item.quantity -= 1
  	item.save()
  	render nothing: true
  end

  def destroy
    OrderItem.find(params[:id]).destroy
    redirect_to order_path params[:order_id]
  end
end
