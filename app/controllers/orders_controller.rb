#!/bin/env ruby
# encoding: utf-8

require 'json'

class OrdersController < ApplicationController
  before_filter :admin_required, except: :create

  def index
    if params[:show] == 'new'
      @orders = Order.where(status: nil).order('created_at DESC')
    elsif params[:show] == 'exec'
      @orders = Order.where(status: true).order('created_at DESC')
    elsif params[:show] == 'exec'
      @orders = Order.where(status: false).order('created_at DESC')
    else
      @orders = Order.all.order('created_at DESC')
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
            option: i['o'],
            size_scode: i['ss'],
            color_scode: i['ls'],
            option_scode: i['os'],
      		})
      	}
        OrderMailer.ordersave(@order).deliver
        OrderMailer.ordersaveclient(@order).deliver
        format.html{redirect_to index_path, notice: 'ordersave'}
      else
        format.html{redirect_to index_path, notice: 'Заказ не был оформлен.'}
      end
    end
	end

  def xlsx
    file = "#{Dir.pwd}/tmp/Заказ.xlsx"
    @workbook = WriteXLSX.new(file)
    @worksheet = @workbook.add_worksheet 'ЗАПОЛНЯЕТ МЕНЕДЖЕР'
    @worksheet.set_tab_color 'red'

    @worksheet.set_column 0, 0, 0.5
    @worksheet.set_column 1, 1, 6
    @worksheet.set_column 2, 2, 10
    @worksheet.set_column 3, 3, 50
    @worksheet.set_column 4, 4, 12
    @worksheet.set_column 5, 5, 7
    @worksheet.set_column 6, 6, 7
    @worksheet.set_column 7, 7, 16
    @worksheet.set_column 8, 8, 0.5

    order = Order.find params[:id]

    def format params
      params[:font] = 'Times New Roman'
      params[:bg_color] || params[:bg_color] = :white
      @style = @workbook.add_format params
    end

    def write row, col, val
      @worksheet.write row, col, val, @style
    end

    def write_xy xy, val
      @worksheet.write xy, val, @style
    end

    def write_row row, col, arr
      for val in arr
        write row, col, val
        col += 1
      end
    end

    def write_step row, col, step, arr
      for val in arr
        write row, col, val
        col += step
      end
    end

    def write_col row, col, arr
      for val in arr
        write row, col, val
        row += 1
      end
    end

    def write_col_row_step row, col, step, arr
      for val in arr
        write_step row, col, step, val
        row += 1
      end
    end

    def merge_range cells, val
      @worksheet.merge_range cells, val, @style
    end

    format({})
    for row in (0..41+order.order_items.size)
      for col in (0..8)
        @worksheet.write_blank row, col, @style
      end
    end

    # Верх

    format(size: 9)
    write_xy 'H1', "Приложение 1"
    format(bold: 1, size: 14, align: :right)
    write 2, 3, "СПЕЦИФИКАЦИЯ К ЗАКАЗУ №"
    format(bold: 1, size: 14, align: :center, border: 1)
    write 2, 4, order.id
    format(bold: 1, size: 11, align: :left)
    write_col 4, 1, ['Дата заказа', 'Салон', 'Менеджер']
    write 8, 1, 'ЗАКАЗЧИК'
    write_col 10, 1, ['ФИО', 'Улица', 'Телефон', 'Ст. метро']
    format(bold: 1, size: 11, align: :left, bottom: 1)
    write 4, 3, order.created_at.strftime('%d.%m.%Y')
    write_step 6, 3, 3, ['Стефаненко Елена', '8(905)750-78-98']
    write_col 10, 3, ["#{order.last_name} #{order.first_name} #{order.middle_name}", order.addr_street, order.phone, '*Ст. метро*']
    write_step 5, 3, 3, ['Вагант', '8(499)400-58-18']
    format(bold: 1, size: 11, align: :right)
    write_col 5, 5, ['телефон  Салона', 'тел. менеджера']
    write_col_row_step 10, 4, 2, [['дом', 'корпус'], ['подъезд', 'этаж'], ['квартира', 'код']]
    write 13, 6, 'лифт'
    format(bold: 1, size: 11, align: :right, bottom: 1)
    write_col_row_step 10, 5, 2, [[order.addr_home, order.addr_block], ['*подъезд*', '*этаж*'], [order.addr_flat, '*код*']]
    write 13, 7, '*лифт*'

    # Таблица

    format(bold: 1, bg_color: '#FFFFCC', size: 10, border: 1, align: :center)
    write_row 15, 1, ['№ п/п', 'Артикул', 'Наименование изделия', 'Цена за ед.', 'Кол-во', '%', 'Сумма']

    row = 16
    count = 0
    price = 0
    for item in order.order_items
      format(size: 10, border: 1, align: :center)
      write_row row, 1, [row - 15, item.product.scode]
      write_row row, 4, [item.product.price, item.quantity, '*скидка*']
      @style.set_align 'left'
      write row, 3, item.product.name
      format(bg_color: '#FFFFCC', color: :red, size: 10, border: 1, align: :right)
      write row, 7, '*цена со скидкой*'
      row += 1
      count += item.quantity
      price += item.product.price * item.quantity # * скидка
    end
    format(size: 10, border: 1, align: :right)
    write_col row, 4, ['Стоимость товара', 'Стоимость доставки']
    format(color: :red, size: 10, border: 1, align: :center)
    write row, 5, count
    format(size: 10, align: :left)
    write row, 6, 'шт.'
    format(color: :red, size: 10, border: 1, align: :right)
    write_col row, 7, [price, '*доставка*', '*Цена с доставкой*']
    format(bold: 1, size: 10, align: :right)
    write row += 2, 4, 'W'

    # Оплата
    format(bold: 1, size: 11, align: :left)
    write_col row += 2, 1, ['Оплачено клиентом', 'Доплата', 'Окончательный расчет']
    format(size: 11, align: :right)
    write_col row, 4, ['дата оплаты'] * 3
    write_col row, 6, ['сумма'] * 3
    format(border: 1, size: 11, align: :right)
    write_col row, 5, ['*дата оплаты*'] * 3
    format(border: 1, size: 11, bold: 1, align: :center)
    write_col row, 7, ['*сумма*'] * 2
    format(border: 1, size: 11, bold: 1, align: :center, color: :red)
    write row, 7, '*сумма*'
    format(size: 11, bold: 1, align: :right, color: :red)
    write row += 4, 4, 'Способ оплаты заказа'

    # Кредит
    format(size: 11, bold: 1, left: 1, top: 1, right: 1)
    merge_range "B#{row += 2}:H#{row}", 'Клиенту предоставлена кредит'
    format(left: 1)
    write_xy "B#{row += 1}", nil
    format(right: 1)
    write_xy "H#{row}", nil
    format(size: 11, bold: 1, left: 1, bottom: 1)
    write_xy "B#{row += 1}", 'На сумму'
    format(size: 10, bottom: 1, align: :center)
    write_xy "C#{row}", nil
    write_xy "D#{row}", '0,00р.'
    write_xy "F#{row}", '0'
    format(size: 11, bottom: 1, align: :rigth, color: :red)
    write_xy "E#{row}", 'МЕСЯЦЕВ'
    format(size: 11, bottom: 1, align: :rigth)
    write_xy "G#{row}", '%'
    format(size: 10, bottom: 1, right: 1, align: :center, bold: 1)
    write_xy "H#{row}", '0'

    # Низ
    format size: 11, bold: 1
    write row += 1, 1, 'С информацией, перечисленной в спецификации согласен'
    format bottom: 1
    write_row row, 4, [nil] * 2
    format size: 11, color: :red
    merge_range "G#{row += 1}:H#{row}", 'Каверин Иван Александрович'
    format size: 11, align: :center, top: 6
    merge_range "B#{row += 2}:H#{row}", 'ИНФОРМАЦИЯ О ДОСТАВКЕ'

    @worksheet = @workbook.add_worksheet 'ЭКЗЕМПЛЯР СКЛАДА'
    @worksheet.set_tab_color 'green'

    @worksheet = @workbook.add_worksheet 'ВОЗВРАТНАЯ НАКЛАДНАЯ'
    @worksheet.set_tab_color 'blue'

    @workbook.close
    send_file file
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
