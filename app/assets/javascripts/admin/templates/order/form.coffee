app.templates.form.order =
	page: ->
		ret = cells [
			[
				td '', attrs: style: 'width: 33.3%'
				td field('Номер', 'number', val_cb: (v) -> if v then v else ''), attrs: style: 'width: 33.3%'
				td '', attrs: style: 'width: 33.3%'
			]
			[
				td ''
				td tb "Статус", 'status', data: {status: {fields: ['name'], pick: true}}
				td ''
			]
			td field "Дата заказа", "created_at", format: date: "dd.MM.yyyy"
			[
				td field 'Салон', 'salon'
				td ''
				td field 'Телефон салона', 'salon_tel'
			]
			[
				td field 'Менеджер', 'manager'
				td ''
				td field 'Телефон менеджера', 'manager_tel'
			]
			td "<h2 class='tal pad m15' style='margin-bottom: 0'>Заказчик</h2>", attrs: colspan: 3
			[
				td field 'Фамилия', 'last_name'
				td field 'Имя', 'first_name'
				td field 'Отчество', 'middle_name'
			]
			[
				td field 'Улица', 'addr_street'
				td field 'Подъезд', 'addr_block'
				td field 'Дом', 'addr_home'
			]
			[
				td field 'Телефон', 'phone'
				td field 'Корпус', 'addr_staircase'
				td field 'Этаж', 'addr_floor'
			]
			[
				td field 'Метро', 'addr_metro'
				td field 'Квартира', 'addr_flat'
				td field 'Код', 'addr_code'
			]
			[
				td ''
				td field 'Лифт', 'addr_elevator'
			]
		]
		ret += "<td colspan='3'>
			<table class='style' style='white-space: nowrap'>
				<tr>
					<th>№ п/п</th>
					<th>Артикул</th>
					<th>Наименование изделия</th>
					<th>Цена за ед.</th>
					<th>Кол-во</th>
					<th>%</th>
					<th colspan='2'>Сумма</th>
				</tr>"
		i = 0
		quantity = 0
		total = 0
		for c in db.where('order_item', order_id: param.id)
			p = db.find_one('product', c.product_id) or article: '', name: ''
			quantity += c.quantity
			price = c.price * c.quantity * (1 - (c.discount / 100))
			total += price
			ret += "<tr>
				<td>#{i += 1}</td>
				<td>#{p.article}</td>
				<td>#{p.name}</td>
				<td>#{c.price.toCurrency()} руб.</td>
				<td>#{c.quantity}</td>
				<td>#{c.discount}</td>
				<td colspan='2' class='price'>#{price.toCurrency()} руб.</td>
			</tr>"
		ret += "<tr>
			<th></th>
			<th colspan='3'>Описание дополнительного товара</th>
			<th colspan='2'>Цена дополнительного товара</th>
			<th colspan='2'></th>
		</tr>"
		for c in db.where('virtproduct', order_id: param.id)
			quantity += 1
			total += parseFloat c.price
			ret += "<tr data-id='#{c.id}'>
				<td>#{i += 1}</td>
				<td colspan='3'>#{c.text}</td>
				<td colspan='2' class='price'>#{c.price.toCurrency()} руб.</td>
				<td colspan='2' class='btn red' onclick='removeVirtproduct(this)'>Удалить</td>
			</tr>"
		window.debt = total + window.rec.deliver_cost
		ret += "<tr>
			<td colspan='8' class='btn green' onclick='addVirtproduct(this)'>Добавить дополнительный товар</td>
		</tr>
		<tr>
			<td colspan='4' class='tar pad'><b>Стоимость товара</b></td>
			<td style='color: red'><b>#{quantity}</b></td>
			<td>шт.</td>
			<td colspan='2'>#{total.toCurrency()} руб.</td>
		</tr>
		<tr>
			<td colspan='4' class='tar pad'><b>Стоимость доставки</b></td>
			<td colspan='2'><label class='row'><p>Тип доставки</p><input type='text' name='deliver_type'#{if rec.deliver_type then " value='#{rec.deliver_type}'" else ''}></label></td>
			<td colspan='2'><input onkeyup='countPrices()' type='text' name='deliver_cost'#{if rec.deliver_cost then " value='#{rec.deliver_cost}'" else ''}></td>
		</tr>
		<tr>
			<td colspan='4' class='tar pad'><b>Итого</b></td>
			<td colspan='2'></td>
			<td colspan='2' id='itogo'>#{(window.debt).toCurrency()} руб.</td>
		</tr>"
		ret += "</table></td>" + cells [
			[
				td "<b>Предоплата</b>"
				td field "Дата предоплаты", "prepayment_date", format: date: "dd.MM.yyyy"
				td field "Сумма предоплаты", "prepayment_sum", {attrs: {onkeyup: "countPrices()"}, format: decimal: "currency"}
			]
			[
				td "<b>Доплата</b>"
				td field "Дата доплаты", "doppayment_date", format: date: "dd.MM.yyyy"
				td field "Сумма доплаты", "doppayment_sum", {attrs: {onkeyup: "countPrices()"}, format: decimal: "currency"}
			]
			[
				td "<b>Окончательный расчет</b>"
				td field "Дата окончательного расчета", "finalpayment_date", format: date: "dd.MM.yyyy"
				td field "Сумма окончательного расчета", "finalpayment_sum", {attrs: {onkeyup: "countPrices()"}, format: decimal: "currency"}
			]
			[
				td ''
				td ''
				td "<b>Долг клиента: <span style='color: red' id='debt'>#{window.debt.toCurrency()} руб.</span></b>"
			]
			[
				td ''
				td ''
				td field "Способ оплаты", "payment_type"
			]
			td "<h2 class='tal pad m15' style='margin-bottom: 0'>Клиенту предоставлен кредит</h2>", attrs: colspan: 3
			[
				td field "Сумма кредита", "credit_sum", {format: decimal: "currency"}
				td field "Кол-Во Месяцев Кредита", "credit_month"
				td field "Проценты кредита", "credit_procent"
			]
			td "<h2 class='tal pad m15' style='margin-bottom: 0'>Информация о доставке</h2>", attrs: colspan: 3
			[
				td field "Дата доставки", "deliver_date"
				td "<b>Сборка</b> - оплата по факту"
				td "<b>Подъем</b> - оплата см. Приложение №2"
			]
			td "<b>* при доставке за пределы МКАД</b>, в стоимость доставки включается фактический киллометраж (за 1 км. - 30р)", attrs: colspan: 3
			td "<h2 class='tal pad m15' style='margin-bottom: 0'>Дополнительная информация</h2>", attrs: colspan: 3
			td "<b>сборка 6%=2200, подъем 300 руб</b>", attrs: colspan: 3
		]
		title('заказ') + form "<table>" + ret + "</table>"
	belongs_to: ["status"]
	has_many: [
		model: 'order_item', belongs_to: ["product"]
		model: 'virtproduct'
	]
	functions:
		addVirtproduct: (el) ->
			tr = $(el).parent()
			tr.before "<tr>
				<td>#{(parseInt(tr.prev().find('td:first-child').html()) or 0) + 1}</td>
				<td colspan='3'><input type='text' placeholder='Описание'></td>
				<td colspan='2' class='inputprice'><input onkeyup='countPrices()' type='text' placeholder='Стоимость'></td>
				<td class='btn green' onclick='saveVirtproduct(this)'>Сохранить</td>
				<td class='btn red' onclick='cancelVirtproduct(this)'>Отменить</td>
			</tr>"
		saveVirtproduct: (el) ->
			el = $ el
			priceTd = el.prev()
			textTd = priceTd.prev()
			text_val = textTd.find('input').val()
			price_val = priceTd.find('input').val()
			params = order_id: param.id, text: text_val, price: price_val
			db.create_one 'virtproduct', params, (id) ->
				el.parent().data 'id', 'id'
				textTd.html text_val
				priceTd.toggleClass('inputprice price').html price_val.toCurrency() + ' руб.'
				priceTd.after "<td colspan='2' class='btn red' onclick='removeVirtproduct(this)'>Удалить</td>"
				el.next().remove()
				el.remove()
		cancelVirtproduct: (el) ->
			$(el).parent().remove()
		removeVirtproduct: (el) ->
			tr = $(el).parent().attr 'id', 'removeRecord'
			ask "Удалить запись?",
				ok:
					html: "Удалить"
					class: "red"
				action: ->
					tr = $('#removeRecord').attr 'id', ''
					id = tr.data 'id'
					db.destroy 'virtproduct', id, ->
						next = tr.next()
						while next.data 'id'
							i = next.find('td:first-child')
							i.html i.html() - 1
							next = next.next()
						tr.remove()
				cancel: -> $('#removeRecord').attr 'id', ''
		countPrices: ->
			total = 0
			$('.price').each -> total += parseFloat @.innerHTML.replace ' ', ''
			$('.inputprice').each -> total += parseFloat $(@).find('input').val().replace ' ', ''
			total += parseFloat($("[name='deliver_cost']").val().replace ' ', '') or 0
			$('#itogo').html total.toCurrency() + ' руб.'
			total -= parseFloat($("[name='prepayment_sum']").val().replace ' ', '') or 0
			total -= parseFloat($("[name='doppayment_sum']").val().replace ' ', '') or 0
			total -= parseFloat($("[name='finalpayment_sum']").val().replace ' ', '') or 0
			$('#debt').html total.toCurrency() + ' руб.'