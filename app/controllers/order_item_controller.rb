class OrderItemController < ApplicationController
	before_filter :manager_required
  layout 'admin'

  def plus
  	item = OrderItem.find(params[:id])
  	item.quantity += 1
  	item.save()
    current_user.manager_log 'Увеличил(а) количество товара', [item.order.id, params[:id]]
  	render nothing: true
  end

  def minus
  	item = OrderItem.find(params[:id])
  	item.quantity -= 1
  	item.save()
    current_user.manager_log 'Уменьшил(а) количество товара', [item.order.id, params[:id]]
  	render nothing: true
  end

  def destroy
    OrderItem.find(params[:id]).destroy
    current_user.manager_log 'Удалил(а) товар из заказа', [item.order.id, params[:id]]
    redirect_to order_path params[:order_id]
  end
end
