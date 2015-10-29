app.templates.form.order =
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs: style: 'width: 33.3%'
						},
						{
							header: 'Номер'
							field: 'number'
							attrs: style: 'width: 33.3%'
						},
						{
							attrs: style: 'width: 33.3%'
						}
					]
				},
				{
					td: [
						{},
						{
							header: 'Статус'
							field: 'status_id'
							belongs_to: 'status'
							treebox:
								data:
									status:
										fields: ['name']
										pick: true
								pick:
									val: 'id'
									header: 'name'
						},
						{}
					]
				},
				{
					td: [
						{
							header: 'Дата заказа'
							field: 'created_at'
							format:
								date: 'dd.MM.YYYY'
						},
						{},
						{}
					]
				},
				{
					td: [
						{
							header: 'Салон'
							field: 'salon'
						},
						{},
						{
							header: 'Телефон Салона'
							field: 'salon_tel'
						}
					]
				},
				{
					td: [
						{
							header: 'Менеджер'
							field: 'manager'
						},
						{},
						{
							header: 'Телефон Менеджера'
							field: 'manager_tel'
						}
					]
				},
				{
					td: [
						{
							html: '<h2 class="tal pad m15" style="margin-bottom: 0">Заказчик</h2>'
							attrs: colspan: 3
						}
					]
				},
				{
					td: [
						{
							header: 'Фамилия'
							field: 'last_name'
						},
						{
							header: 'Имя'
							field: 'first_name'
						},
						{
							header: 'Отчество'
							field: 'middle_name'
						}
					]
				},
				{
					td: [
						{
							header: 'Улица'
							field: 'addr_street'
						},
						{
							header: 'Подъезд'
							field: 'addr_block'
						},
						{
							header: 'Дом'
							field: 'addr_home'
						}
					]
				},
				{
					td: [
						{
							header: 'Телефон'
							field: 'phone'
						},
						{
							header: 'Корпус'
							field: 'addr_staircase'
						},
						{
							header: 'Этаж'
							field: 'addr_floor'
						}
					]
				},
				{
					td: [
						{
							header: 'Метро'
							field: 'addr_metro'
						},
						{
							header: 'Квартира'
							field: 'addr_flat'
						},
						{
							header: 'Код'
							field: 'addr_code'
						}
					]
				},
				{
					td: [
						{},
						{
							header: 'Лифт'
							field: 'addr_elevator'
							attrs: style: 'margin-bottom: 32px'
						},
						{}
					]
				},
				{
					td: [
						only: 'update'
						attrs: colspan: 3
						table: [
							{
								attrs: class: 'style'
								tr: [
									{
										td: [
											{
												th: true
												html: '№ п/п'
											},
											{
												th: true
												html: 'Артикул'
											},
											{
												th: true
												html: 'Наименование изделия'
											},
											{
												th: true
												html: 'Цена за ед.'
											},
											{
												th: true
												html: 'Кол-во'
											},
											{
												th: true
												html: '%'
											},
											{
												th: true
												html: 'Сумма'
												attrs: colspan: 2
											},
										]
									},
									{
										before: (params) ->
											vars.quantity += params.rec.quantity
											vars.price += params.rec.price * params.rec.quantity * (1 - (params.rec.discount / 100))
										collection:
											type: 'has_many'
											model: 'order_item'
										td: [
											{
												set: -> @html = vars.i += 1
											},
											{
												belongs_to: 'product'
												show: 'scode'
											},
											{
												belongs_to: 'product'
												show: 'name'
											},
											{
												set: (params) -> @html = params.rec.price.toCurrency() + ' руб.'
											},
											{
												show: 'quantity'
											},
											{
												show: 'discount'
											},
											{
												set: (params) ->
													@html = (params.rec.price * params.rec.quantity * (1 - (params.rec.discount / 100))).toCurrency() + ' руб.'
												attrs: colspan: 2
											}
										]
									},
									{
										td: [
											{
												th: true
											},
											{
												th: true
												html: 'Описание дополнительного товара'
												attrs: colspan: 3
											},
											{
												th: true
												html: 'Цена дополнительного товара'
												attrs: colspan: 2
											},
											{
												th: true
												attrs: colspan: 2
											}
										]
									},
									{
										before: (params) ->
											vars.quantity += 1
											vars.price += parseFloat params.rec.price
										collection:
											type: 'has_many'
											model: 'virtproduct'
										td: [
											{
												set: (params) -> @html = vars.i += 1
											},
											{
												show: 'text'
												attrs: colspan: 3
											},
											{
												set: (params) -> @html = params.rec.price.toCurrency() + ' руб.'
												attrs: colspan: 2
											},
											{
												html: 'Удалить'
												attrs:
													onclick: 'functions.destroyVirtproduct(this)'
													colspan: 2
													class: 'btn red'
												set: (params) -> @attrs['data-id'] = params.rec.id
											}
										]
									},
									{
										td: [
											{
												attrs:
													class: 'btn green'
													colspan: 8
													onclick: "functions.addVirtproduct(this)"
												html: 'Добавить дополнительный товар'
											}
										]
									},
									{
										td: [
											{
												attrs:
													class: 'tar b pad'
													colspan: 4
												html: 'Стоимость товара'
											},
											{
												attrs:
													style: 'color: red'
													class: 'b'
													colspan: 1
												set: -> @html = vars.quantity
											},
											{
												html: 'шт.'
											},
											{
												attrs:
													colspan: 2
													id: 'price'
												set: ->
													@attrs['data-price'] = vars.price
													@html = vars.price.toCurrency() + ' руб.'
											}
										]
									},
									{
										td: [
											{
												attrs:
													class: 'tar b pad'
													colspan: 4
												html: 'Стоимость доставки'
											},
											{
												header: 'Тип доставки'
												field: 'deliver_type'
												level: 0
												attrs: colspan: 2
											},
											{
												field: 'deliver_cost'
												fieldAttrs:
													onkeyup: 'functions.countPrice()'
													id: 'deliver-cost-input'
												level: 0
												attrs:
													colspan: 2
											}
										]
									},
									{
										td: [
											{
												html: 'Итого'
												attrs:
													colspan: 4
													class: 'tar b pad'
											},
											{
												attrs: colspan: 2
											},
											{
												set: (params) ->
													@html = (vars.price + (params.rec.deliver_cost || 0)).toCurrency() + ' руб.'
												attrs:
													colspan: 2
													id: 'final-price'
											}
										]
									}
								]
							}
						]
					]
				},
				{
					td: [
						{
							only: 'create'
							attrs: colspan: 3
							table: [
								{
									tr: [
										{
											td: [
												{
													header: 'Дата доставки'
													field: 'deliver_date'
												},
												{
													header: 'Стоимость доставки'
													field: 'deliver_cost'
												}
											]
										}
									]
								}
							]
						}
					]
				}
				{
					td: [
						{
							attrs: class: 'b'
							html: 'Предоплата'
						},
						{
							header: 'Дата предоплаты'
							field: 'prepayment_date'
						},
						{
							header: 'Сумма предоплаты'
							field: 'prepayment_sum'
							fieldAttrs:
								onkeyup: 'functions.countPrice()'
								id: 'prepayment-sum'
						}
					]
				},
				{
					td: [
						{
							attrs: class: 'b'
							html: 'Доплата'
						},
						{
							header: 'Дата доплаты'
							field: 'doppayment_date'
						},
						{
							header: 'Сумма доплаты'
							field: 'doppayment_sum'
							fieldAttrs:
								onkeyup: 'functions.countPrice()'
								id: 'doppayment-sum'
						}
					]
				},
				{
					td: [
						{
							attrs: class: 'b'
							html: 'Окончательный расчет'
						},
						{
							header: 'Дата окончательного расчета'
							field: 'finalpayment_date'
						},
						{
							header: 'Сумма окончательного расчета'
							field: 'finalpayment_sum'
							fieldAttrs:
								onkeyup: 'functions.countPrice()'
								id: 'finalpayment-sum'
						}
					]
				},
				{
					td: [
						{},
						{},
						{
							set: (params) ->
								payed = 0
								payed += params.rec.prepayment_sum if params.rec.prepayment_sum
								payed += params.rec.doppayment_sum if params.rec.doppayment_sum
								payed += params.rec.finalpayment_sum if params.rec.finalpayment_sum
								@html = "<b>Долг клиента: <span style='color: red' id='debt'>#{(vars.price - payed).toCurrency()} руб.</span></b>"
						}
					]
				},
				{
					td: [
						{},
						{},
						{
							header: "Способ оплаты"
							field: 'payment_type'
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: 'tal pad'
								colspan: 3
							html: '<h2>Клиенту предоставлен кредит</h2>'
						}
					]
				},
				{
					td: [
						{
							header: 'Сумма кредита'
							field: 'credit_sum'
						},
						{
							header: 'Кол-Во Месяцев Кредита'
							field: 'credit_month'
						},
						{
							header: 'Проценты кредита'
							field: 'credit_procent'
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: 'tal pad'
								colspan: 3
							html: '<h2>Информация о доставке</h2>'
						}
					]
				},
				{
					td: [
						{
							header: 'Дата доставки'
							field: 'deliver_date'
						},
						{
							html: '<b>Сборка</b> - оплата по факту'
						},
						{
							html: '<b>Подъем</b> - оплата см. Приложение №2'
						}
					]
				},
				{
					td: [
						{
							html: '<b>* при доставке за пределы МКАД</b>, в стоимость доставки включается фактический киллометраж (за 1 км. - 30р)'
							attrs: colspan: 3
						}
					]
				},
				{
					td: [
						{
							html: '<h2>Дополнительная информация</h2>'
							attrs:
								class: 'tal pad'
								colspan: 3
						}
					]
				},
				{
					td: [
						{
							html: '<b>сборка 6%=2200, подъем 300 руб</b>'
							attrs: colspan: 3
						}
					]
				}
			]
		}
	]
	belongs_to: [
		model: 'status'
	]
	has_many: [
		{
			model: 'order_item', belongs_to: {model: 'product'}
		},
		{
			model: 'virtproduct'
		}
	]
	vars: {i: 0, quantity: 0, price: 0}
	functions:
		addVirtproduct: (el) ->
			$(el).parent().before "<tr>
				<td>#{vars.i += 1}</td>
				<td colspan='3'><input type='text' placeholder='Описание'></td>
				<td colspan='2'><input class='virtproduct-price-input' onkeyup='functions.countPrice()' type='text' placeholder='Стоимость'></td>
				<td class='btn green' onclick='functions.createVirtproduct(this)'>Сохранить</td>
				<td class='btn red' onclick='functions.removeVirtproduct(this)'>Отменить</td>
			</tr>"
		removeVirtproduct: (el) ->
			tr = $(el).parent()
			vars.i -= 1
			next = tr.next()
			until next.find('td').length is 1
				td = next.find('td').eq(0)
				td.html td.html() - 1
				next = next.next()
			tr.remove()
		createVirtproduct: (el) ->
			td = $(el)
			tdPrice = td.prev()
			price = parseFloat tdPrice.find('input').val()
			tdText = tdPrice.prev()
			text = tdText.find('input').val()
			if price
				models.virtproduct.create order_id: param.id, text: text, price: price, 'Дополнительный товар добавлен', (id) ->
					tdText.html text
					vars.price += price
					tdPrice.html price.toCurrency() + ' руб.'
					td.next().remove()
					td.remove()
					tdPrice.after "<td colspan='2' class='btn red' data-id='#{id}' onclick='functions.destroyVirtproduct(this)'>Удалить</td>"
		destroyVirtproduct: (el) ->
			el = $ el
			models.virtproduct.destroy el.data('id'), msg: 'Удалить дополнительный товар?', cb: ->
				vars.i -= 1
				tr = el.parent()
				next = tr.next()
				until next.find('td').length is 1
					td = next.find('td').eq(0)
					td.html td.html() - 1
					next = next.next()
				tr.remove()
				functions.countPrice()
		countPrice: (el) ->
			virts = 0
			$('.virtproduct-price-input').each ->
				p = parseFloat $(@).val()
				virts += p if p
			price = virts + vars.price
			$('#price').html price.toCurrency() + ' руб.'
			deliver = parseFloat $('#deliver-cost-input').val()
			price += deliver if deliver
			$('#final-price').html price.toCurrency() + ' руб.'
			prepayment = parseFloat $('#prepayment-sum').val()
			doppayment = parseFloat $('#doppayment-sum').val()
			finalpayment = parseFloat $('#finalpayment-sum').val()
			price -= prepayment if prepayment
			price -= doppayment if doppayment
			price -= finalpayment if finalpayment
			$('#debt').html price.toCurrency() + ' руб.'