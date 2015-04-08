app.templates.index.order =
	header: [['Статус', '22%'], ['Дата заказа', '22%'], ['Телефон', '22%'], ['Сумма заказа', '22%'], 'Действия']
	table: [
		{
			tr: [
				{
					setPlain: "(rec) -> @attrs = \"data-id\": rec.id"
					td: [
						{
							attrs:
								style: "width: 22%"
							show: "name"
							header: "Статус"
							belongs_to: "status"
						},
						{
							attrs:
								style: "width: 22%"
							show: "created_at"
							header: "Дата заказа"
							format:
								date: "dd.MM.yyyy"
						},
						{
							attrs:
								style: "width: 22%"
							header: "Телефон"
							show: "phone"
						},
						{
							attrs:
								style: "width: 22%"
							header: "Сумма заказа"
							set: (rec) ->
								price = 0
								price += r.price * r.quantity * (1 - r.discount / 100) for r in rec.order_items()
								price += parseFloat r.price for r in rec.virtproducts()
								@html = price.toCurrency() + ' руб.'
							setPlain: "(rec) ->\n\tprice = 0\n\tprice += r.price * r.quantity * (1 - r.discount / 100) for r in rec.order_items()\n\tprice += parseFloat r.price for r in rec.virtproducts()\n\t@html = price.toCurrency() + ' руб.'"
						},
						{
							attrs:
								class: 'btn blue'
							header: "Сохранить в \"xlsx\""
							set: (rec) ->
								@html = "<a href='/admin/ordergen/#{rec.id}/Заказ#{if me.prefix then " #{me.prefix} " else ''} #{rec.number or rec.id}.xlsx'><i class='icon-print'></i></a>"
							setPlain: "set: (rec) -> @html = \"<a href='/admin/ordergen/\#{rec.id}/Заказ\#{if me.prefix then \" \#{me.prefix} \" else ''} \#{rec.number or rec.id}.xlsx'><i class='icon-print'></i></a>\""
						},
						{
							attrs:
								class: 'btn orange'
							header: "Редактировать"
							set: (rec) ->
								@html = "<a onclick='app.aclick(this)' href='/admin/model/#{param.model}/edit/#{rec.id}'><i class='icon-pencil3'></i></a>"
							setPlain: "(rec) -> @html = \"<a onclick='app.aclick(this)' href='/admin/model/\#{param.model}/edit/\#{rec.id}'><i class='icon-pencil3'></i></a>\""
						},
						{
							attrs:
								class: 'btn red'
							header: "Удалить"
							html: "<div onclick='functions.removeRecord(this)'><i class='icon-remove3'></i></div>"
						}
					]
				}
			]
		}
	]
	belongs_to: [
		model: "status"
	]
	belongs_to_plain: "[\n\tmodel: \"status\"\n]"
	has_many: [
		{model: "order_item"},
		{model: "virtproduct"}
	]
	has_many_plain: "[\n\t{model: \"order_item\"},\n\t{model: \"virtproduct\"}\n]"
	functions:
		removeRecord: (el) ->
			tr = $(this).parents('tr')
			models[param.model].destroy tr.data('id'), cb: -> tr.remove()
	functions_plain: "removeRecord: (el) ->\n\ttr = $(this).parents('tr')\n\tmodels[param.model].destroy tr.data('id'), cb: -> tr.remove()"