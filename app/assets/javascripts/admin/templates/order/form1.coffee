app.templates.form.order =
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								style: "width: 33.3%"
						},
						{
							attrs:
								style: "width: 33.3%"
							header: "Номер"
							field: "number"
						},
						{
							attrs:
								style: "width: 33.3%"
						}
					]
				},
				{
					td: [
						{
						},
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
						},
						{
						}
					]
				},
				{
					td: [
						{
							header: "Дата заказа"
							field: "created_at"
							format:
								date: "dd.MM.YYYY"
						},
						{
						},
						{
						}
					]
				},
				{
					td: [
						{
							header: "Салон"
							field: "salon"
						},
						{
						},
						{
							header: "Телефон Салона"
							field: "salon_tel"
						}
					]
				},
				{
					td: [
						{
							header: "Менеджер"
							field: "manager"
						},
						{
						},
						{
							header: "Телефон Менеджера"
							field: "manager_tel"
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							html: "<h2 class=\"tal pad m15\" style=\"margin-bottom: 0\">Заказчик</h2>"
						}
					]
				},
				{
					td: [
						{
							header: "Фамилия"
							field: "last_name"
						},
						{
							header: "Имя"
							field: "first_name"
						},
						{
							header: "Отчество"
							field: "middle_name"
						}
					]
				},
				{
					td: [
						{
							header: "Улица"
							field: "addr_street"
						},
						{
							header: "Подъезд"
							field: "addr_block"
						},
						{
							header: "Дом"
							field: "addr_home"
						}
					]
				},
				{
					td: [
						{
							header: "Телефон"
							field: "phone"
						},
						{
							header: "Корпус"
							field: "addr_staircase"
						},
						{
							header: "Этаж"
							field: "addr_floor"
						}
					]
				},
				{
					td: [
						{
							header: "Метро"
							field: "addr_metro"
						},
						{
							header: "Квартира"
							field: "addr_flat"
						},
						{
							header: "Код"
							field: "addr_code"
						}
					]
				},
				{
					td: [
						{
						},
						{
							attrs:
								style: "margin-bottom: 32px"
							header: "Лифт"
							field: "addr_elevator"
						},
						{
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							only: "update"
							table: [
								{
									attrs:
										class: "style"
									tr: [
										{
											td: [
												{
													html: "№ п/п"
													th: true
												},
												{
													html: "Артикул"
													th: true
												},
												{
													html: "Наименование изделия"
													th: true
												},
												{
													html: "Цена за ед."
													th: true
												},
												{
													html: "Кол-во"
													th: true
												},
												{
													html: "%"
													th: true
												},
												{
													attrs:
														colspan: "2"
													html: "Сумма"
													th: true
												}
											]
										},
										{
											set: (data) ->
												vars.quantity += data.rec.quantity
												vars.price += data.rec.price * data.rec.quantity * (1 - (data.rec.discount / 100))
											setPlain: "(data) ->\n\tvars.quantity += data.rec.quantity\n\tvars.price += data.rec.price * data.rec.quantity * (1 - (data.rec.discount / 100))"
											collection:
												type: "has_many"
												model: "order_item"
											td: [
												{
													set: -> @html = vars.i += 1
													setPlain: "-> @html = vars.i += 1"
												},
												{
													belongs_to: "product"
													show: "scode"
												},
												{
													belongs_to: "product"
													show: "name"
												},
												{
													set: (data) -> @html = data.rec.price.toCurrency() + ' руб.'
													setPlain: "(data) -> @html = data.rec.price.toCurrency() + ' руб.'"
												},
												{
													show: "quantity"
												},
												{
													show: "discount"
												},
												{
													attrs:
														colspan: "2"
													set: (data) ->
														@html = (data.rec.price * data.rec.quantity * (1 - (data.rec.discount / 100))).toCurrency() + ' руб.'
													setPlain: "(data) ->\n\t@html = (data.rec.price * data.rec.quantity * (1 - (data.rec.discount / 100))).toCurrency() + ' руб.'"
												}
											]
										},
										{
											td: [
												{
													th: true
												},
												{
													attrs:
														colspan: "3"
													html: "Описание дополнительного товара"
													th: true
												},
												{
													attrs:
														colspan: "2"
													html: "Цена дополнительного товара"
													th: true
												},
												{
													attrs:
														colspan: "2"
													th: true
												}
											]
										},
										{
											set: (data) ->
												vars.quantity += 1
												vars.price += parseFloat data.rec.price
											setPlain: "(data) ->\n\tvars.quantity += 1\n\tvars.price += parseFloat data.rec.price"
											collection:
												type: "has_many"
												model: "virtproduct"
											td: [
												{
													set: (data) -> @html = vars.i += 1
													setPlain: "(data) -> @html = vars.i += 1"
												},
												{
													attrs:
														colspan: "3"
													show: "text"
												},
												{
													attrs:
														colspan: "2"
													set: (data) -> @html = data.rec.price.toCurrency() + ' руб.'
													setPlain: "(data) -> @html = data.rec.price.toCurrency() + ' руб.'"
												},
												{
													attrs:
														onclick: "functions.destroyVirtproduct(this)"
														colspan: "2"
														class: "btn red"
													html: "Удалить"
													set: (data) -> @attrs['data-id'] = data.rec.id
													setPlain: "(data) -> @attrs['data-id'] = data.rec.id"
												}
											]
										},
										{
											td: [
												{
													attrs:
														class: "btn green"
														colspan: "8"
														onclick: "functions.addVirtproduct(this)"
													html: "Добавить дополнительный товар"
												}
											]
										},
										{
											td: [
												{
													attrs:
														class: "tar b pad"
														colspan: "4"
													html: "Стоимость товара"
												},
												{
													attrs:
														style: "color: red"
														class: "b"
														colspan: "1"
													set: -> @html = vars.quantity
													setPlain: "-> @html = vars.quantity"
												},
												{
													html: "шт."
												},
												{
													attrs:
														colspan: "2"
														id: "price"
													set: ->
														@attrs['data-price'] = vars.price
														@html = vars.price.toCurrency() + ' руб.'
													setPlain: "->\n\t@attrs['data-price'] = vars.price\n\t@html = vars.price.toCurrency() + ' руб.'"
												}
											]
										},
										{
											td: [
												{
													attrs:
														class: "tar b pad"
														colspan: "4"
													html: "Стоимость доставки"
												},
												{
													attrs:
														colspan: "2"
													header: "Тип доставки"
													field: "deliver_type"
												},
												{
													attrs:
														colspan: "2"
													field: "deliver_cost"
													fieldAttrs:
														onkeyup: "functions.countPrice()"
														id: "deliver-cost-input"
												}
											]
										},
										{
											td: [
												{
													attrs:
														colspan: "4"
														class: "tar b pad"
													html: "Итого"
												},
												{
													attrs:
														colspan: "2"
												},
												{
													attrs:
														colspan: "2"
														id: "final-price"
													set: (data) -> @html = (vars.price + (data.rec.deliver_cost || 0)).toCurrency() + ' руб.'
													setPlain: "(data) -> @html = (vars.price + (data.rec.deliver_cost || 0)).toCurrency() + ' руб.'"
												}
											]
										}
									]
								}
							]
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							only: "create"
							table: [
								{
									tr: [
										{
											td: [
												{
													header: "Дата доставки"
													field: "deliver_date"
												},
												{
													header: "Стоимость доставки"
													field: "deliver_cost"
												}
											]
										}
									]
								}
							]
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: "b"
							html: "Предоплата"
						},
						{
							header: "Дата предоплаты"
							field: "prepayment_date"
						},
						{
							header: "Сумма предоплаты"
							field: "prepayment_sum"
							fieldAttrs:
								onkeyup: "functions.countPrice()"
								id: "prepayment-sum"
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: "b"
							html: "Доплата"
						},
						{
							header: "Дата доплаты"
							field: "doppayment_date"
						},
						{
							header: "Сумма доплаты"
							field: "doppayment_sum"
							fieldAttrs:
								onkeyup: "functions.countPrice()"
								id: "doppayment-sum"
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: "b"
							html: "Окончательный расчет"
						},
						{
							header: "Дата окончательного расчета"
							field: "finalpayment_date"
						},
						{
							header: "Сумма окончательного расчета"
							field: "finalpayment_sum"
							fieldAttrs:
								onkeyup: "functions.countPrice()"
								id: "finalpayment-sum"
						}
					]
				},
				{
					td: [
						{
						},
						{
						},
						{
							set: (data) ->
								payed = 0
								payed += data.rec.prepayment_sum if data.rec.prepayment_sum
								payed += data.rec.doppayment_sum if data.rec.doppayment_sum
								payed += data.rec.finalpayment_sum if data.rec.finalpayment_sum
								@html = "Долг клиента: #{(vars.price - payed).toCurrency()} руб."
							setPlain: "(data) ->\n\tpayed = 0\n\tpayed += data.rec.prepayment_sum if data.rec.prepayment_sum\n\tpayed += data.rec.doppayment_sum if data.rec.doppayment_sum\n\tpayed += data.rec.finalpayment_sum if data.rec.finalpayment_sum\n\t@html = \"Долг клиента: \#{(vars.price - payed).toCurrency()} руб.\""
						}
					]
				},
				{
					td: [
						{
						},
						{
						},
						{
							header: "Способ оплаты"
							field: "payment_type"
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: "tal pad"
								colspan: "3"
							html: "<h2>Клиенту предоставлен кредит</h2>"
						}
					]
				},
				{
					td: [
						{
							header: "Сумма кредита"
							field: "credit_sum"
						},
						{
							header: "Кол-Во Месяцев Кредита"
							field: "credit_month"
						},
						{
							header: "Проценты кредита"
							field: "credit_procent"
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: "tal pad"
								colspan: "3"
							html: "<h2>Информация о доставке</h2>"
						}
					]
				},
				{
					td: [
						{
							header: "Дата доставки"
							field: "deliver_date"
						},
						{
							html: "<b>Сборка</b> - оплата по факту"
						},
						{
							html: "<b>Подъем</b> - оплата см. Приложение №2"
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							html: "<b>* при доставке за пределы МКАД</b>, в стоимость доставки включается фактический киллометраж (за 1 км. - 30р)"
						}
					]
				},
				{
					td: [
						{
							attrs:
								class: "tal pad"
								colspan: "3"
							html: "<h2>Дополнительная информация</h2>"
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							html: "<b>сборка 6%=2200, подъем 300 руб</b>"
						}
					]
				}
			]
		}
	]
	belongs_to: [
			model: 'status'
		]
	belongs_to_plain: "[\n\tmodel: 'status'\n]"
	has_many: [
			{
				model: 'order_item', belongs_to: {model: 'product'}
			},
			{
				model: 'virtproduct'
			}
		]
	has_many_plain: "[\n\t{\n\t\tmodel: 'order_item', belongs_to: {model: 'product'}\n\t},\n\t{\n\t\tmodel: 'virtproduct'\n\t}\n]"
	vars:
		i: 0
		quantity: 0
		price: 0
	vars_plain: "i: 0\nquantity: 0\nprice: 0"
	functions:
		addVirtproduct: (el) ->
			$(el).parent().before "<tr><td>#{vars.i += 1}</td><td colspan='3'><input type='text' placeholder='Описание'></td><td colspan='2'><input class='virtproduct-price-input' onkeyup='functions.countPrice()' type='text' placeholder='Стоимость'></td><td class='btn green' onclick='functions.createVirtproduct(this)'>Сохранить</td><td class='btn red' onclick='functions.removeVirtproduct(this)'>Отменить</td></tr>"
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
	functions_plain: "addVirtproduct: (el) ->\n\t$(el).parent().before \"<tr><td>\#{vars.i += 1}</td><td colspan='3'><input type='text' placeholder='Описание'></td><td colspan='2'><input class='virtproduct-price-input' onkeyup='functions.countPrice()' type='text' placeholder='Стоимость'></td><td class='btn green' onclick='functions.createVirtproduct(this)'>Сохранить</td><td class='btn red' onclick='functions.removeVirtproduct(this)'>Отменить</td></tr>\"\nremoveVirtproduct: (el) ->\n\ttr = $(el).parent()\n\tvars.i -= 1\n\tnext = tr.next()\n\tuntil next.find('td').length is 1\n\t\ttd = next.find('td').eq(0)\n\t\ttd.html td.html() - 1\n\t\tnext = next.next()\n\ttr.remove()\ncreateVirtproduct: (el) ->\n\ttd = $(el)\n\ttdPrice = td.prev()\n\tprice = parseFloat tdPrice.find('input').val()\n\ttdText = tdPrice.prev()\n\ttext = tdText.find('input').val()\n\tif price\n\t\tmodels.virtproduct.create order_id: param.id, text: text, price: price, 'Дополнительный товар добавлен', (id) ->\n\t\t\ttdText.html text\n\t\t\tvars.price += price\n\t\t\ttdPrice.html price.toCurrency() + ' руб.'\n\t\t\ttd.next().remove()\n\t\t\ttd.remove()\n\t\t\ttdPrice.after \"<td colspan='2' class='btn red' data-id='\#{id}' onclick='functions.destroyVirtproduct(this)'>Удалить</td>\"\ndestroyVirtproduct: (el) ->\n\tel = $ el\n\tmodels.virtproduct.destroy el.data('id'), msg: 'Удалить дополнительный товар?', cb: ->\n\t\tvars.i -= 1\n\t\ttr = el.parent()\n\t\tnext = tr.next()\n\t\tuntil next.find('td').length is 1\n\t\t\ttd = next.find('td').eq(0)\n\t\t\ttd.html td.html() - 1\n\t\t\tnext = next.next()\n\t\ttr.remove()\n\t\tfunctions.countPrice()\ncountPrice: (el) ->\n\tvirts = 0\n\t$('.virtproduct-price-input').each ->\n\t\tp = parseFloat $(@).val()\n\t\tvirts += p if p\n\tprice = virts + vars.price\n\t$('#price').html price.toCurrency() + ' руб.'\n\tdeliver = parseFloat $('#deliver-cost-input').val()\n\tprice += deliver if deliver\n\t$('#final-price').html price.toCurrency() + ' руб.'\n\tprepayment = parseFloat $('#prepayment-sum').val()\n\tdoppayment = parseFloat $('#doppayment-sum').val()\n\tfinalpayment = parseFloat $('#finalpayment-sum').val()\n\tprice -= prepayment if prepayment\n\tprice -= doppayment if doppayment\n\tprice -= finalpayment if finalpayment\n\t$('#debt').html price.toCurrency() + ' руб.'"