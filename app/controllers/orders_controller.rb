#!/bin/env ruby
# encoding: utf-8

require 'json'

class OrdersController < ApplicationController
  before_filter :admin_required, except: :create

  def index
    if params[:show] == 'new'
      @orders = Order.where status: nil
    elsif params[:show] == 'exec'
      @orders = Order.where status: true
    elsif params[:show] == 'exec'
      @orders = Order.where status: false
    else
      @orders = Order.all
    end
  end

  def exec
    Order.find(params[:id]).update status: true
    redirect_to orders_path
  end

  def deny
    Order.find(params[:id]).update status: false
    redirect_to orders_path
  end

  def destroy
    Order.find(params[:id]).destroy
    redirect_to orders_path
  end

  def show
    @order = Order.find params[:id]
  end

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
            option: i['o']
      		})
      	}
        OrderMailer.ordersave(@order).deliver
        OrderMailer.ordersaveclient(@order).deliver
        format.html{redirect_to index_path, notice: 'Заказ был успешно оформлен.'}
      else
        format.html{redirect_to index_path, notice: 'Заказ не был оформлен.'}
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
