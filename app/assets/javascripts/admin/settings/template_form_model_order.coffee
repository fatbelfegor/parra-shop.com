@settings.template.form.model.order =
	headers: [{name: 'number', validate: ['presence'], type: 'integer'}]
	treebox: [{name: 'id'}]
	rows: [
		{cols: [null, {name: 'status_id', type: 'belongs_to'}, null], margin: 32}
		{cols: [{name: 'created_at'}, null, null]}
		{cols: [{name: 'salon'}, null, {name: 'salon_tel'}]}
		{cols: [{name: 'manager'}, null, {name: 'manager_tel'}], margin: 32}
		{cols: [{name: 'Заказчик', type: 'h2'}]}
		{cols: [{name: 'last_name'}, {name: 'first_name'}, {name: 'middle_name'}]}
		{cols: [{name: 'addr_street'}, {name: 'addr_block'}, {name: 'addr_home'}]}
		{cols: [{name: 'phone'}, {name: 'addr_staircase'}, {name: 'addr_floor'}]}
		{cols: [{name: 'addr_metro'}, {name: 'addr_flat'}, {name: 'addr_code'}]}
		{cols: [null, {name: 'addr_elevator'}, null], margin: 32}
		{cols: [{
				type: 'table'
				rows: [{
					cols: [], id: 'order_items_rows'}
				]
			}], margin: 32
		}
		{cols: [{name: 'Предоплата', type: 'b'}, {name: 'prepayment_date'}, {name: 'prepayment_sum', default: '0'}]}
		{cols: [{name: 'Доплата', type: 'b'}, {name: 'doppayment_date'}, {name: 'doppayment_sum', default: '0'}]}
		{cols: [{name: 'Окончательный расчет', type: 'b'}, {name: 'finalpayment_date'}, {name: 'finalpayment_sum', default: '0'}]}
		{cols: [null, null, {name: "<b>Долг клиента:</b> <b style='color: red'>123</b>", type: 'custom'}]}
		{cols: [null, null, {name: 'pay_type'}]}
		{cols: [{name: 'Клиенту предоставлен кредит', type: 'h2'}]}
		{cols: [{name: 'credit_sum', default: '0'}, {name: 'credit_month'}, {name: 'credit_procent', default: '0.00'}]}
		{cols: [{name: 'Информация о доставке', type: 'h2'}]}
		{cols: [{name: 'deliver_date'}, {name: '<b>Сборка</b> - оплата по факту', type: 'custom'}, {name: "<b>Подъем</b> - оплата см. Приложение №2", type: 'custom'}]}
		{cols: [{name: "<b>* при доставке за пределы МКАД</b>, в стоимость доставки включается фактический киллометраж (за 1 км. - 30р)", type: 'custom'}]}
		{cols: [{name: 'Дополнительная информация', type: 'h2'}]}
		{cols: [{name: 'сборка 6%=2200, подъем 300 руб', type: 'b'}]}
	]
	hidden: ['id','position','updated_at']
	cb: ->
		name = app.data.route.model
		id = parseInt app.data.route.id
		if id
			for rec in tables[name].records
				if rec.id is id
					data = [{model: 'order_item', belongs_to: ['product']}, {model: 'virtproduct'}]
					data[0][name + '_id'] = data[1][name + '_id'] = rec.id
					record.ask data, ->
						ret = ""
						count = total = 0
						for r in tables['order_item'].records
							if r.order_id is rec.id
								for p in tables['product'].records
									if p.id is r.product_id
										price = r.price * r.quantity * (1 - r.discount/100)
										total += price
										ret += "<tr>
										<td>#{count += 1}</td>
										<td>#{p.scode}</td>
										<td>#{p.name}</td>
										<td><span id='price'>#{r.price}</span> руб.</td>
										<td id='quantity'>#{r.quantity}</td>
										<td id='discount'>#{r.discount}</td>
										<td><span id='sum'>#{(price).toFixed 2}</span> руб.</td>
										</tr>"
										break
						ret += "<tr>
						<th></th>
						<th colspan='3'>Описание дополнительного товара</th>
						<th colspan='2'>Цена дополнительного товара</th>
						<th></th>
						</tr>"
						for r in tables['virtproduct'].records
							if r.order_id is rec.id
								total += parseInt r.price
								ret += "<tr>
								<td>#{count += 1}</td>
								<td colspan='3'>#{r.text}</td>
								<td colspan='2'>#{r.price}</td>
								<td class='btn red'>Удалить</td>
								</tr>"
						ret += "<tr>
							<td colspan='7' class='btn green'>
								<a href='/admin/model/virtproduct/new?order_id=#{rec.id}' onclick='app.aclick(this, {back: \"Редактирование заказа №#{rec.number}\"})'>Добавить дополнительный товар</a>
							</td>
						</tr>
						<tr>
							<td colspan='4' class='b tar pad'>Стоимость товара</td>
							<td class='b' style='color: red'>#{count}</td>
							<td>шт.</td>
							<td class='b' style='color: red'><span id='total'>#{total}</span> руб.</td>
						</tr>
						<tr>
							<td colspan='4' class='b tar pad'>Стоимость доставки</td>
							<td colspan='2'><input type='text' name='record[deliver_type]' value='#{rec.deliver_type}' placeholder='Тип доставки'></td>
							<td><input type='text' name='record[deliver_cost]' value='#{rec.deliver_cost}'></td>
						</tr>
						<tr>
							<td colspan='4' class='b tar pad'>Итого</td>
							<td colspan='2'></td>
							<td class='b'><span id='end-price'>#{total - rec.deliver_cost}</span> руб.</td>
						</tr>"
						$('#order_items_rows').html("<th>№ п/п</th><th>Артикул</th><th>Наименование изделия</th><th>Цена за ед.</th><th>Кол-во</th><th>%</th><th>Сумма</th>").after ret
					break