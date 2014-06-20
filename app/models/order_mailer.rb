#!/bin/env ruby
# encoding: utf-8

class OrderMailer < ActionMailer::Base
  default from: 'Parra Shop'

  def ordersave(order)
    p order
    mail(to: 'orders@parra-shop.ru', subject: 'Поступил новый заказ.')
  end

  def ordersaveclient(order)
    mail(to: order.email, subject: 'Ваш заказ принят.')
  end
end