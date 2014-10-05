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
        if user_signed_in? && current_user.admin?
            format.html{redirect_to @order}
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

  def xlsx
    file = "#{Dir.pwd}/tmp/Заказ.xlsx"
    @workbook = WriteXLSX.new(file)
    @worksheet = @workbook.add_worksheet 'ЗАПОЛНЯЕТ МЕНЕДЖЕР'
    @worksheet.set_tab_color 'red'

    def set_columns_width columns
      for column in columns
        @worksheet.set_column column[0], column[0], column[1]
      end
    end
    set_columns_width [[0, 0.5], [1, 6], [2, 10], [3, 50], [4, 12], [5, 7], [6, 7], [7, 16], [8, 0.5]]

    order = Order.find params[:id]

    def format params
      if params.is_a? Hash
        params[:font] = 'Times New Roman'
        params[:bg_color] ||= :white
        @style = @workbook.add_format params
      else
        @style = []
        for param in params
          param[:font] = 'Times New Roman'
          param[:bg_color] = :white
          @style << @workbook.add_format(param)
        end
      end
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
    items = row - 16
    format(size: 10, border: 1, align: :right)
    write_col row, 4, ['Стоимость товара', 'Стоимость доставки']
    format(color: :red, size: 10, border: 1, align: :center)
    write row, 5, count
    format(size: 10, align: :left)
    write row, 6, 'шт.'
    format(color: :red, size: 10, border: 1, align: :right)
    write_col row, 7, [price, '*доставка*', '*Цена с доставкой*']
    format(bold: 1, size: 10, align: :right)
    write row += 2, 4, 'Стоимость доставки'

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
    format(size: 11, bottom: 1, align: :right, color: :red)
    write_xy "E#{row}", 'месяцев'
    format(size: 11, bottom: 1, align: :right)
    write_xy "G#{row}", '%'
    format(size: 10, bottom: 1, right: 1, align: :center, bold: 1)
    write_xy "H#{row}", '0'

    # Подпись
    format size: 11, bold: 1
    merge_range "B#{row += 3}:H#{row}", 'ИНФОРМАЦИЯ О ДОСТАВКЕ'
    write_xy "B#{row += 1}", 'Доставка до'
    write_xy "D#{row}", '10.09.2014 в первой половине дня'
    write_xy "B#{row + 3}", 'Дополнительная информация'
    @worksheet.set_row(row-1, 32)
    format [{size: 11, bold: 1}, {size: 11}]
    @worksheet.write_rich_string "E#{row}", @style[0], 'Сборка - ', @style[1], 'оплата по факту', @style[0], "\nПодъем - ", @style[1], 'оплата см. Приложение №2'
    @worksheet.write_rich_string "B#{row += 1}", @style[0], '* при доставке за пределы МКАД, ', @style[1], 'в стоимость доставки включается фактический километраж (за 1 км. - 30р)'
    format size: 13, bold: 1, bottom: 1
    merge_range "B#{row += 3}:H#{row += 1}", 'сборка 6%=2200, подъем 300 руб'
    format size: 11, align: :center
    merge_range "B#{row += 1}:H#{row += 1}", "Уважаемый клиент, при возникновении гарантийного случая направляйте претензии на электронную почту\nparrarekl@gmail.com  или по телефону  +7 (926) 154-50-60 ( пн-пт. с 10:00 до 17:00, сб.-вс. выходные дни)."

    # Низ
    format size: 11, bold: 1
    write row += 1, 1, 'С информацией, перечисленной в спецификации согласен'
    format bottom: 1
    write_row row, 4, [nil] * 2
    format size: 11, color: :red
    merge_range "G#{row += 1}:H#{row}", 'Каверин Иван Александрович'

    @worksheet = @workbook.add_worksheet 'ЭКЗЕМПЛЯР СКЛАДА'
    @worksheet.set_tab_color 'green'

    @style = @workbook.add_format bg_color: :white
    set_columns_width [[0, 0.5], [1, 6], [2, 10], [3, 50], [4, 12], [5, 7], [6, 7], [7, 16], [8, 0.5]]

    format({})
    for row in (0..41+items+items)
      for col in (0..8)
        @worksheet.write_blank row, col, @style
      end
    end

    format size: 10
    write_xy "B1", 'Экземпляр склада'
    write_xy "B#{items + 24}", 'Экземпляр склада'
    format size: 11, bold: 1, align: :right
    write_xy 'D2', 'ОТГРУЗОЧНАЯ НАКЛАДНАЯ К ЗАКАЗУ №'
    write_xy "D#{items + 25}", 'ДОПОСТАВКА К ЗАКАЗУ №'
    format size: 11, bold: 1
    write_xy 'B4', 'Менеджер'
    write_xy 'B6', 'Водитель'
    write_xy 'B14', 'ЗАКАЗЧИК'
    write_xy 'B16', 'ФИО'
    write_xy 'E16', 'дом'
    write_xy 'G16', 'корпус'
    write_xy 'B17', 'Улица'
    write_xy 'E17', 'подъезд'
    write_xy 'G17', 'этаж'
    write_xy 'B18', 'Телефон'
    write_xy 'E18', 'квартира'
    write_xy 'G18', 'код'
    write_xy 'B19', 'Ст. метро'
    write_xy 'G19', 'лифт'
    write_xy "B#{items + 27}", 'Менеджер'
    write_xy "B#{items + 29}", 'Водитель'
    write_xy "B#{items + 37}", 'ЗАКАЗЧИК'
    write_xy 'D16', 'Дардыкин Андрей Александрович'
    format size: 11, bold: 1, align: :right
    write_xy "G4", 'Дата отгрузки'
    write_xy "G6", 'Оплата водителю'
    write_xy "G8", 'Подъем за наш счет'
    write_xy "G10", 'Сборка за наш счет'
    write_xy "G12", 'Долг заказчика'
    write_xy "G14", 'Заказчик оплатил '
    write_xy "G#{items + 27}", 'Дата отгрузки'
    write_xy "G#{items + 29}", 'Оплата водителю'
    write_xy "G#{items + 31}", 'Подъем за наш счет'
    write_xy "G#{items + 33}", 'Сборка за наш счет'
    write_xy "G#{items + 35}", 'Долг заказчика'
    write_xy "G#{items + 37}", 'Заказчик оплатил'
    format size: 18, bold: 1, border: 1, align: :center
    write_xy 'E2', order.id
    write_xy "E#{items + 25}", order.id
    format size: 11, bold: 1, border: 1
    write_xy 'D4', 'Стефаненко Елена'
    write_xy 'D6', 'Василий'
    write_xy "D#{items + 27}", 'Стефаненко Елена'
    write_xy "D#{items + 29}", 'Василий'
    write_xy "D#{items + 37}", 'Дардыкин Андрей Александрович'
    format size: 11, align: :right, bg_color: '#FFFFCC', border: 1
    write_xy 'H4', ''
    write_xy 'H6', '0,00р.'
    write_xy 'H8', '0,00р.'
    write_xy 'H10', '0,00р.'
    write_xy "H#{items + 27}", ''
    write_xy "H#{items + 29}", '0,00р.'
    write_xy "H#{items + 31}", '0,00р.'
    write_xy "H#{items + 33}", '0,00р.'
    format size: 11, align: :right, bg_color: '#FFFFCC', bold: 1, border: 1
    write_xy 'H14', ''
    write_xy "H#{items + 37}", '0,00р.'
    format size: 11, align: :right, bg_color: '#FFFF00', border: 1
    write_xy 'H12', '60 940,05р.'
    write_xy "H#{items + 35}", '60 940,05р.'
    format size: 11
    write_xy 'D17', 'Электромонтажный проезд'
    write_xy 'D18', '89254115749(Андрей)89672737817(Дарья)'
    write_xy 'D19', 'Подольск'
    format size: 11, align: :center
    write_xy 'F16', '9'
    write_xy 'F17', '2'
    write_xy 'F18', '90'
    write_xy 'H16', '0'
    write_xy 'H17', '6'
    write_xy 'H18', '0'
    format size: 11, align: :center, bottom: 1
    write_xy 'H19', ''
    format size: 10, align: :center, bold: 1, border: 1
    write_row 20, 1, ['№ п/п', 'Артикул']
    merge_range 'D21:E21', 'Наименование изделия'
    write_xy 'F21', 'Кол-во'
    merge_range 'G21:H21', 'Комментарий'
    write_row items + 38, 1, ['№ п/п', 'Артикул']
    merge_range "D#{items + 39}:E#{items + 39}", 'Наименование изделия'
    write_xy "F#{items + 39}", 'Кол-во'
    merge_range "G#{items + 39}:H#{items + 39}", 'Комментарий'
    format size: 10, align: :center, border: 1
    row = 21
    for item in order.order_items
      write_xy "B#{row += 1}", row - 21
      write_xy "C#{row}", item.product.scode
      write_xy "F#{row}", item.quantity
      merge_range "G#{row}:H#{row}", ''
    end
    row = items + 39
    for item in order.order_items
      write_xy "B#{row += 1}", row - items - 39
      write_xy "C#{row}", item.product.scode
      write_xy "F#{row}", item.quantity
      merge_range "G#{row}:H#{row}", ''
    end
    format size: 10, bottom: 1
    row = 21
    for item in order.order_items
      write_xy "D#{row += 1}", item.product.name
      write_xy "E#{row}", ''
    end
    row = items + 39
    for item in order.order_items
      write_xy "D#{row += 1}", item.product.name
      write_xy "E#{row}", ''
    end
    format size: 10, bold: 1, align: :right
    write_xy "E#{items + 22}", 'ИТОГО К ДОСТАВКЕ'
    write_xy "E#{items + items + 40}", 'ИТОГО К ДОСТАВКЕ'
    format size: 10, bold: 1, align: :center, color: :red
    write_xy "F#{items + 22}", '2'
    write_xy "F#{items + items + 40}", '2'
    format size: 10, bold: 1
    write_xy "G#{items + 22}", 'ПРЕДМЕТОВ'

    @worksheet = @workbook.add_worksheet 'ВОЗВРАТНАЯ НАКЛАДНАЯ'
    @worksheet.set_tab_color 'blue'

    @style = @workbook.add_format bg_color: :white
    set_columns_width [[0, 0.5], [1, 6], [2, 10], [3, 50], [4, 12], [5, 7], [6, 7], [7, 16], [8, 0.5]]

    format({})
    for row in (0..50+items)
      for col in (0..8)
        @worksheet.write_blank row, col, @style
      end
    end

    format size: 10
    write_xy 'B1', 'Экземпляр склада'
    format size: 11, align: :right, bold: 1
    write_xy 'D2', 'ВОЗВРАТНАЯ НАКЛАДНАЯ К ЗАКАЗУ №'
    format size: 18, bold: 1, align: :center, border: 1
    write_xy 'E2', order.id
    format size: 11, bold: 1
    write_xy 'B2', 'Менеджер'
    write_xy 'B4', 'Водитель'
    write_xy 'B10', 'ЗАКАЗЧИК'
    write_xy 'B12', 'ФИО'
    write_xy 'B13', 'Улица'
    write_xy 'B14', 'Телефон'
    write_xy 'B15', 'Ст. метро'
    write_xy 'E12', 'дом'
    write_xy 'E13', 'подъезд'
    write_xy 'E14', 'квартира'
    write_xy 'G12', 'корпус'
    write_xy 'G13', 'этаж'
    write_xy 'G14', 'код'
    write_xy 'G15', 'лифт'
    format size: 11, bold: 1, align: :right
    write_xy 'G4', 'Дата возврата'
    write_xy 'G6', 'Оплата водителю'
    write_xy 'G8', 'Демонтаж за наш счет'
    write_xy 'G10', 'Возвращено заказчику'
    format size: 11, bold: 1, border: 1
    write_xy 'D4', 'Стефаненко Елена'
    write_xy 'D6', 'Водитель'
    format size: 11, align: :right, bg_color: '#FFFFCC', border: 1
    write_xy 'H4', ''
    write_xy 'H6', '0,00р.'
    write_xy 'H8', '0,00р.'
    format size: 11, align: :right, bg_color: '#FFFF00', border: 1
    write_xy 'H10', '0,00р.'
    format size: 11, bold: 1
    write_xy 'D12', 'Дардыкин Андрей Александрович'
    format size: 11
    write_xy 'D13', 'Электромонтажный проезд'
    write_xy 'D14', '89254115749(Андрей)89672737817(Дарья)'
    write_xy 'D13', 'Подольск'
    format size: 11, align: :center
    write_xy 'F12', '9'
    write_xy 'F13', '2'
    write_xy 'F14', '90'
    write_xy 'H12', '0'
    write_xy 'H13', '6'
    write_xy 'H14', '0'
    format size: 11, align: :center, bottom: 1
    write_xy 'H15', ''
    format size: 10, bold: 1, border: 1, align: :center
    write_row 16, 1, ['№ п/п', 'Артикул']
    merge_range 'D17:E17', 'Наименование изделия'
    write_xy 'F17', 'Кол-во'
    merge_range 'G17:H17', 'причина возврата'
    format size: 10, align: :center, border: 1
    row = 17
    for item in order.order_items
      write_xy "B#{row += 1}", row - 17
      write_xy "C#{row}", item.product.scode
      write_xy "F#{row}", item.quantity
      merge_range "G#{row}:H#{row}", ''
    end
    format size: 10, bottom: 1
    row = 17
    for item in order.order_items
      merge_range "D#{row += 1}:E#{row}", item.product.name
      merge_range "G#{row}:H#{row}", ''
    end
    format size: 10, bold: 1, align: :center, color: :red
    write_xy "F#{18+items}", count
    format size: 10, bold: 1, align: :right
    write_xy "E#{18+items}", 'ИТОГО К ВОЗВРАТУ'
    format size: 10, bold: 1
    write_xy "G#{18+items}", 'ПРЕДМЕТОВ'

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
