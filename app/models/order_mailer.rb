#!/bin/env ruby
# encoding: utf-8

class OrderMailer < ActionMailer::Base
  default from: 'Parra Shop'

  def ordersave(order)
    p order
    @order =  order
    mail(to: 'intrtz@gmail.com', subject: 'Поступил новый заказ.')
  end

  def ordersaveclient(order)
    @order =  order
    mail(to: order.email, subject: 'Ваш заказ принят.')
  end
end