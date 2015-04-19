app.templates.index.order =
	page: (recs) ->
		ret = header [['Статус', '22%'], ['Дата заказа', '22%'], ['Телефон', '22%'], ['Сумма заказа', '22%'], 'Действия']
		html = ""
		for rec in recs
			window.rec = rec
			status = db.status.records[rec.status_id]
			price = 0
			for r in db.find('order_item', rec.order_item_ids)
				if r
					price += r.price * r.quantity * (1 - r.discount / 100)
			for r in db.find('virtproduct', rec.virtproduct_ids)
				if r
					price += parseFloat r.price
			html += group tr [
				td (if status then "<p>#{status.name}</p>" else "<p>Без статуса</p>"), attrs: style: 'width: 22%'
				show 'created_at', {format: {date: "dd.MM.yyyy"}, attrs: style: 'width: 22%'}
				show 'phone', attrs: style: 'width: 22%'
				td "<p>#{price.toCurrency()} руб.</p>", attrs: style: 'width: 22%'
				"<td class='btn blue'><a href='/admin/ordergen/#{rec.id}/Заказ#{if me.prefix then " #{me.prefix} " else ''} #{rec.number or rec.id}.xlsx'><i class='icon-print'></i></a></td>"
				buttons()
			]
		ret + records html
	belongs_to: ['status']
	has_many: ['order_item', 'virtproduct']