#!/bin/env ruby
# encoding: utf-8

class OrderMailer < ActionMailer::Base
  default from: 'Parra Shop'

  def ordersave(order)
    @order =  order
    #mail(to: 'intrtz@gmail.com', subject: 'Поступил новый заказ.')
    #mail(to: 'kas1082@yandex.ru', subject: 'Поступил новый заказ.')
    mail(to: ['info@gde-edim.ru', 'info@dreamdev.ru'], subject: 'Поступил новый заказ.'),
  end

  def ordersaveclient(order)
    @order = order
    if(!order.email.empty?)
      mail(to: order.email, subject: 'Ваш заказ принят.')
    end
  end

  def comment(comment)
    @comment = comment
    mail(to: 'kas1082@yandex.ru', subject: 'Новый отзыв на сайте parra-shop.')
  end
end