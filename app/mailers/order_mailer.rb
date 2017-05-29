class OrderMailer < ActionMailer::Base
  default from: 'Parra Shop <orders@parra-shop.ru>'

  def ordersave(order)
    @order = order
    #mail(to: 'intrtz@gmail.com', subject: 'Поступил новый заказ.')
    #mail(to: 'kas1082@yandex.ru', subject: 'Поступил новый заказ.')
    #mail(to: 'ikishik@gmail.com', subject: 'Поступил новый заказ.')
    #mail(to: ['ikishik@gmail.com', 'ekishik@gmail.com'], subject: 'Поступил новый заказ.')
    OrderExcel.new order.id, nil do |f|
      attachments["#{order.id}.xlsx"] = f
    end
    mail(to: ['intrtz@gmail.com', 'kas1082@yandex.ru'], subject: 'Поступил новый заказ.')
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
