app.templates.form.order =
	table: [
		{
			tr: [
				{
					td: [
						{
							style: 'width: 33.3%'
						},
						{
							header: 'Номер'
							field: 'number'
							style: 'width: 33.3%'
						},
						{
							style: 'width: 33.3%'
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
							colspan: 3
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
							style: 'margin-bottom: 32px'
						},
						{}
					]
				},
				{
					td: [
						only: 'update'
						colspan: 3
						table: [
							{
								class: 'style'
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
												colspan: 2
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
												cb: (params) -> vars.i += 1
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
												show: 'price'
												cb: (price) ->
													price.toCurrency() + ' руб.'
											},
											{
												show: 'quantity'
											},
											{
												show: 'discount'
											},
											{
												cb: (params) ->
													(params.rec.price * params.rec.quantity * (1 - (params.rec.discount / 100))).toCurrency() + ' руб.'
												colspan: 2
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
												colspan: 3
											},
											{
												th: true
												html: 'Цена дополнительного товара'
												colspan: 2
											},
											{
												th: true
												colspan: 2
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
												cb: (params) -> vars.i += 1
											},
											{
												show: 'text'
												colspan: 3
											},
											{
												cb: (params) -> params.rec.price.toCurrency() + ' руб.'
												colspan: 2
											},
											{
												class: 'btn red'
												html: 'Удалить'
												colspan: 2
												click: 'functions.destroyVirtproduct(this)'
												td_cb: (params) -> " data-id='#{params.rec.id}'"
											}
										]
									},
									{
										td: [
											{
												class: 'btn green'
												html: 'Добавить дополнительный товар'
												colspan: 8
												click: "functions.addVirtproduct(this)"
											}
										]
									},
									{
										td: [
											{
												class: 'tar b pad'
												html: 'Стоимость товара'
												colspan: 4
											},
											{
												style: 'color: red'
												class: 'b'
												cb: (params) ->
													vars.quantity
												colspan: 1
											},
											{
												html: 'шт.'
											},
											{
												cb: (params) ->
													vars.price.toCurrency() + ' руб.'
												colspan: 2
											}
										]
									},
									{
										td: [
											{
												class: 'tar b pad'
												html: 'Стоимость доставки'
												colspan: 4
											},
											{
												header: 'Тип доставки'
												field: 'deliver_type'
												level: 0
												colspan: 2
											},
											{
												field: 'deliver_cost'
												level: 0
												colspan: 2
											}
										]
									},
									{
										td: [
											{
												class: 'tar b pad'
												html: 'Итого'
												colspan: 4
											},
											{
												colspan: 2
											},
											{
												cb: (params) ->
													(vars.price + (params.rec.deliver_cost || 0)).toCurrency() + ' руб.'
												colspan: 2
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
							colspan: 3
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
							class: 'b'
							html: 'Предоплата'
						},
						{
							header: 'Дата предоплаты'
							field: 'prepayment_date'
						},
						{
							header: 'Сумма предоплаты'
							field: 'prepayment_sum'
						}
					]
				},
				{
					td: [
						{
							class: 'b'
							html: 'Доплата'
						},
						{
							header: 'Дата доплаты'
							field: 'doppayment_date'
						},
						{
							header: 'Сумма доплаты'
							field: 'doppayment_sum'
						}
					]
				},
				{
					td: [
						{
							class: 'b'
							html: 'Окончательный расчет'
						},
						{
							header: 'Дата окончательного расчета'
							field: 'finalpayment_date'
						},
						{
							header: 'Сумма окончательного расчета'
							field: 'finalpayment_sum'
						}
					]
				},
				{
					td: [
						{},
						{},
						{
							cb: (params) ->
								payed = 0
								payed += params.rec.prepayment_sum if params.rec.prepayment_sum
								payed += params.rec.doppayment_sum if params.rec.doppayment_sum
								payed += params.rec.finalpayment_sum if params.rec.finalpayment_sum
								"<b>Долг клиента: <span style='color: red'>#{(vars.price - payed).toCurrency()} руб.</span></b>"
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
							class: 'tal pad'
							html: '<h2>Клиенту предоставлен кредит</h2>'
							colspan: 3
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
							class: 'tal pad'
							html: '<h2>Информация о доставке</h2>'
							colspan: 3
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
							colspan: 3
						}
					]
				},
				{
					td: [
						{
							class: 'tal pad'
							html: '<h2>Дополнительная информация</h2>'
							colspan: 3
						}
					]
				},
				{
					td: [
						{
							html: '<b>сборка 6%=2200, подъем 300 руб</b>'
							colspan: 3
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
				<td colspan='2'><input type='text' placeholder='Стоимость'></td>
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
			price = tdPrice.find('input').val()
			tdText = tdPrice.prev()
			text = tdText.find('input').val()
			models.virtproduct.create order_id: param.id, text: text, price: price, 'Дополнительный товар добавлен', (id) ->
				tdText.html text
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