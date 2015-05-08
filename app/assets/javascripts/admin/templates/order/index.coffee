app.templates.index.order =
	order: 'created_at asc'
	page: (recs) ->
		ret = header
			name: 'Заказы'
			header: [['Статус', '22%'], ['Дата заказа', '22%'], ['Телефон', '22%'], 'Сумма заказа', ['Действия', 'min']]
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
				td "<p>#{price.toCurrency()} руб.</p>"
				buttons()
			]
		ret + records html
	belongs_to: ['status']
	has_many: ['order_item', 'virtproduct']
	select: ['created_at', 'phone', 'status_id']