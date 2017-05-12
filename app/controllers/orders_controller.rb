#!/bin/env ruby
# encoding: utf-8

require 'json'

class OrdersController < ApplicationController
  before_filter :manager_required, except: :create
  layout 'admin'

    def index
        if params[:status].present?
            @orders = Status.find(params[:status]).orders.order('created_at DESC')
        else
            @orders = Order.all.order('created_at DESC')
        end
        @statuses = Status.all
    end

    def destroy
        Order.find(params[:id]).destroy
        current_user.manager_log 'Удалил(а) заказ', params[:id]
        redirect_to orders_path
    end

    def show
        @order = Order.find params[:id]
    end

	def create
        if params[:cartfield]
            items = JSON.parse params[:cartfield]
            if items.any?
                order = Order.new

                order.first_name = params[:name]
                order.last_name = params[:lastname]
                order.phone = params[:phone]
                order.email = params[:email]

                order.deliver_type = params[:delivery]
                order.city = params[:city] # Добавить
                order.addr_street = params[:addr_street]
                order.addr_home = params[:addr_home]
                order.addr_block = params[:addr_block]
                order.addr_staircase = params[:addr_staircase]
                order.addr_floor = params[:addr_floor]
                order.addr_flat = params[:addr_flat]

                order.loyality_card = params[:loyality_card] # Добавить
                order.payment_type = params[:payment_type]
                
                if order.save
                    items.each do |i|
                        order.order_items.create({
                            product_id: i['i'],
                            quantity: i['c'],
                            price: i['p'].gsub(' ', ''),
                            size: i['s'],
                            color: i['l'],
                            option: i['o'],
                            size_scode: i['ss'],
                            color_scode: i['ls'],
                            option_scode: i['os']
                        })
                    end
                    if user_signed_in? && (current_user.admin? || current_user.manager)
                        redirect_to "/orders/#{order.id}/edit"
                    else
                        begin
                            OrderMailer.ordersave(order).deliver
                            OrderMailer.ordersaveclient(order).deliver
                        rescue Exception => e
                        end
                        redirect_to '/', notice: 'ordersave'
                    end
                    cookies.delete :cart
                    return
                end
            end
        end
        format.html{redirect_to '/', notice: 'Заказ не был оформлен.'}
	end

    def edit
        @order = Order.find params[:id]
    end

    def update
        Order.find(params[:id]).update order_params
        current_user.manager_log 'Редактировал(а) заказ', params[:id]
        redirect_to orders_path
    end

    def discount_save
        if params[:p].present? and params[:id].present?
            order_item = OrderItem.find(params[:id])
            order_item.update discount: params[:p]
            current_user.manager_log "Установил(а) скидку #{params[:p]}% на товар", [order_item.order.id, params[:id]]
        end
        render nothing: true
    end

    def addVirtproduct
        vp = Order.find(params[:id]).virtproducts.create text: params[:text], price: params[:price]
        render text: vp.id
    end

    def editVirtproductText
        Virtproduct.find(params[:id]).update text: params[:val]
        render nothing: true
    end

    def editVirtproductPrice
        Virtproduct.find(params[:id]).update price: params[:val]
        render nothing: true
    end

    def destroyVirtproduct
        Virtproduct.find(params[:id]).destroy
        render nothing: true
    end

    def status
        Order.find(params[:id]).update status_id: params[:status_id]
        render nothing: true
    end

  def xlsx
    OrderExcel.new params[:id], current_user do |f|
      send_data f, type: "text/excel"
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
		:comment,
        :salon,
        :salon_tel,
        :manager,
        :manager_tel,
        :addr_metro,
        :addr_staircase,
        :addr_floor,
        :addr_code,
        :addr_elevator,
        :deliver_type,
        :deliver_cost,
        :prepayment_date,
        :prepayment_sum,
        :doppayment_date,
        :doppayment_sum,
        :finalpayment_date,
        :finalpayment_sum,
        :payment_type,
        :credit_sum,
        :credit_month,
        :credit_procent,
        :deliver_date,
        :number
    )
  end
end
