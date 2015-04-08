app.templates.form.order =
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs: style: 'width: 33.3%'
						}
						{
							attrs: style: 'width: 33.3%'
							header: "Номер"
							field: "number"
						}
						{
							attrs: style: 'width: 33.3%'
						}
					]
				}
				{
					td: [
						{}
						{
							header: "Статус"
							field: "status_id"
							belongs_to: "status"
							treebox:
								data:
									status:
										fields: ['name']
										pick: true
								pick:
									val: "id"
									header: "name"
						}
					]
				}
				{
					td: [
						{
							header: "Дата заказа"
							field: "created_at"
							format: date: "dd.MM.yyyy"
						}
					]
				}
				{
					td: [
						{
							header: "Салон"
							field: "salon"
						}
						{}
						{
							header: "Телефон салона"
							field: "salon_tel"
						}
					]
				}
				{
					td: [
						{
							header: "Менеджер"
							field: "manager"
						}
						{}
						{
							header: "Телефон менеджера"
							field: "manager_tel"
						}
					]
				}
				{
					td: [
						{
							attrs: colspan: 3
							html: "<h2 class='tal pad m15' style='margin-bottom: 0'>Заказчик</h2>"
						}
					]
				}
				{
					td: [
						{
							header: "Фамилия"
							field: "last_name"
						}
						{
							header: "Имя"
							field: "first_name"
						}
						{
							header: "Отчество"
							field: "middle_name"
						}
					]
				}
				{
					td: [
						{
							header: "Улица"
							field: "addr_street"
						}
						{
							header: "Подъезд"
							field: "addr_block"
						}
						{
							header: "Дом"
							field: "addr_home"
						}
					]
				}
				{
					td: [
						{
							header: "Телефон"
							field: "phone"
						}
						{
							header: "Корпус"
							field: "addr_staircase"
						}
						{
							header: "Этаж"
							field: "addr_floor"
						}
					]
				}
				{
					td: [
						{
							header: "Метро"
							field: "addr_metro"
						}
						{
							header: "Квартира"
							field: "addr_flat"
						}
						{
							header: "Код"
							field: "addr_code"
						}
					]
				}
				{
					td: [
						{}
						{
							header: "Лифт"
							field: "addr_elevator"
						}
					]
				}
				{
					td: [
						{
							attrs: colspan: 3
							set: (rec) ->
								ret = "<table class='style'>
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
								for c in rec.order_items()
									p = c.product()
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
								for c in rec.virtproducts()
									quantity += 1
									total += parseFloat c.price
									ret += "<tr data-id='#{c.id}'>
										<td>#{i += 1}</td>
										<td colspan='3'>#{c.text}</td>
										<td colspan='2' class='price'>#{c.price.toCurrency()} руб.</td>
										<td colspan='2' class='btn red' onclick='functions.removeVirtproduct(this)'>Удалить</td>
									</tr>"
								window.debt = total + rec.deliver_cost
								ret += "<tr>
									<td colspan='8' class='btn green' onclick='functions.addVirtproduct(this)'>Добавить дополнительный товар</td>
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
									<td colspan='2'><input onkeyup='functions.countPrices()' type='text' name='deliver_cost'#{if rec.deliver_cost then " value='#{rec.deliver_cost}'" else ''}></td>
								</tr>
								<tr>
									<td colspan='4' class='tar pad'><b>Итого</b></td>
									<td colspan='2'></td>
									<td colspan='2' id='itogo'>#{(window.debt).toCurrency()} руб.</td>
								</tr>"
								ret += "</table>"
								@html = ret
						}
					]
				}
				{
					td: [
						{
							html: "<b>Предоплата</b>"
						}
						{
							header: "Дата предоплаты"
							field: "prepayment_date"
							format: date: "dd.MM.yyyy"
						}
						{
							header: "Сумма предоплаты"
							field: "prepayment_sum"
							fieldAttrs: onkeyup: "functions.countPrices()"
							format: decimal: "currency"
						}
					]
				}
				{
					td: [
						{
							html: "<b>Доплата</b>"
						}
						{
							header: "Дата доплаты"
							field: "doppayment_date"
							fieldAttrs: onkeyup: "functions.countPrices()"
							format: date: "dd.MM.yyyy"
						}
						{
							header: "Сумма доплаты"
							field: "doppayment_sum"
							fieldAttrs: onkeyup: "functions.countPrices()"
							format: decimal: "currency"
						}
					]
				}
				{
					td: [
						{
							html: "<b>Окончательный расчет</b>"
						}
						{
							header: "Дата окончательного расчета"
							field: "finalpayment_date"
							format: date: "dd.MM.yyyy"
						}
						{
							header: "Сумма окончательного расчета"
							field: "finalpayment_sum"
							fieldAttrs: onkeyup: "functions.countPrices()"
							format: decimal: "currency"
						}
					]
				}
				{
					td: [
						{}
						{}
						{
							set: ->
								@html = "<b>Долг клиента: <span style='color: red' id='debt'>#{window.debt.toCurrency()} руб.</span></b>"
						}
					]
				}
				{
					td: [
						{}
						{}
						{
							header: "Способ оплаты"
							field: "payment_type"
						}
					]
				}
				{
					td: [
						{
							attrs: colspan: 3
							html: "<h2 class='tal pad m15' style='margin-bottom: 0'>Клиенту предоставлен кредит</h2>"
						}
					]
				}
				{
					td: [
						{
							header: "Сумма кредита"
							field: "credit_sum"
						}
						{
							header: "Кол-Во Месяцев Кредита"
							field: "credit_month"
						}
						{
							header: "Проценты кредита"
							field: "credit_procent"
						}
					]
				}
				{
					td: [
						{
							attrs: colspan: 3
							html: "<h2 class='tal pad m15' style='margin-bottom: 0'>Информация о доставке</h2>"
						}
					]
				}
				{
					td: [
						{
							header: "Дата доставки"
							field: "deliver_date"
						}
						{
							html: "<b>Сборка</b> - оплата по факту"
						}
						{
							html: "<b>Подъем</b> - оплата см. Приложение №2"
						}
					]
				}
				{
					td: [
						{
							attrs: colspan: 3
							html: "<b>* при доставке за пределы МКАД</b>, в стоимость доставки включается фактический киллометраж (за 1 км. - 30р)"
						}
					]
				}
				{
					td: [
						{
							attrs: colspan: 3
							html: "<h2 class='tal pad m15' style='margin-bottom: 0'>Дополнительная информация</h2>"
						}
					]
				}
				{
					td: [
						{
							attrs: colspan: 3
							html: "<b>сборка 6%=2200, подъем 300 руб</b>"
						}
					]
				}
			]
		}
	]
	belongs_to: [
		{model: "status"}
	]
	has_many: [
		{model: "order_item", belongs_to: {model: "product"}}
		{model: "virtproduct"}
	]
	functions:
		addVirtproduct: (el) ->
			tr = $(el).parent()
			tr.before "<tr>
				<td>#{(parseInt(tr.prev().find('td:first-child').html()) or 0) + 1}</td>
				<td colspan='3'><input type='text' placeholder='Описание'></td>
				<td colspan='2' class='inputprice'><input onkeyup='functions.countPrices()' type='text' placeholder='Стоимость'></td>
				<td class='btn green' onclick='functions.saveVirtproduct(this)'>Сохранить</td>
				<td class='btn red' onclick='functions.cancelVirtproduct(this)'>Отменить</td>
			</tr>"
		saveVirtproduct: (el) ->
			el = $ el
			priceTd = el.prev()
			textTd = priceTd.prev()
			text = textTd.find('input').val()
			price = priceTd.find('input').val()
			data = {relation: [{model: 'virtproduct', new_records: [fields: {order_id: param.id, price: price, text: text}]}]}
			formData =  new FormData()
			formData.append "relation[0]model", 'virtproduct'
			formData.append "relation[0]new_records[0]fields[order_id]", param.id
			formData.append "relation[0]new_records[0]fields[price]", price
			formData.append "relation[0]new_records[0]fields[text]", text
			record.save data, formData: formData, cb: (res) ->
				el.parent().data 'id', res.relation[0].new_records[0].record.id
				textTd.html text
				priceTd.toggleClass('inputprice price').html price.toCurrency() + ' руб.'
				priceTd.after "<td colspan='2' class='btn red' onclick='functions.removeVirtproduct(this)'>Удалить</td>"
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
					$.ajax
						url: "/admin/model/virtproduct/destroy/#{id}"
						type: 'POST'
						contentType: false
						processData: false
						dataType: "json"
						success: (res) ->
							if res is 'permission denied'
								notify 'Доступ запрещен', class: 'red'
							else
								next = tr.next()
								while next.data 'id'
									i = next.find('td:first-child')
									i.html i.html() - 1
									next = next.next()
								tr.remove()
								delete models['virtproduct'].collection[id]
								notify "Запись удалена"
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