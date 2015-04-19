app.templates.index.packinglist =
	page: (recs) ->
		packs = ""
		price = 0
		for pack in recs
			items_price = 0
			amount = 0
			all_products = true
			for item in db.where('packinglistitem', packinglist_id: pack.id)
				all_products = false unless item.product_id
				items_price += item.price * (amount += item.amount)
			price += items_price
			packs += "<tr data-id='#{pack.id}'>
				<td class='btn always "
			if all_products
				packs += "green"
			else
				packs += "red"
			packs += "'>#{pack.date}</td>
				<td>#{pack.doc_number}</td>
				<td>#{items_price.toCurrency()} руб.</td>
				<td>#{amount}</td>
				<td><a class='btn blue' href='/admin/model/packinglist/edit/#{pack.id}' onclick='app.click(this)'>Открыть</a></td>
				<td class='btn red' onclick='packinglist_destroy(this)'>Удалить</td>
			</tr>"
		"<h1>Товарные накладные</h1>
		<div class='content'>
			<label class='text-center'><div class='btn blue ib m15'>Выбрать файл накладной (HTML)</div><div class='hide'></div><input class='hide' onchange='packinglist_upload(this)' type='file' multiple></label>
			<div class='form' style='width: 350px; margin: 0 auto'>
				<table>
					<tr>
						<td></td>
						<td><div class='row'><p>Общая стоимость: <span id='total_price'>#{price.toCurrency()}</span> руб.</p></div></td>
						<td></td>
					</tr>
				</table>
			</div>
			<table class='style' id='packinglistTable'>
				<tr>
					<th>Дата/Статус</th>
					<th>№ Накладной</th>
					<th>Сумма</th>
					<th>Общее кол-во товаров</th>
					<th></th>
					<th></th>
				</tr>
				#{packs}
			</table>
			<br>
		</div>"
	has_many: "packinglistitem"
	functions:
		packinglist_upload: (input) ->
			if input.files
				for f in input.files
					reader = new FileReader()
					reader.onload = (e) ->
						html = $ $.parseHTML e.target.result
						pack = user: me.email
						items = []
						html.find('td').each ->
							el = $(@)
							if el.text() is 'Номердокумента'
								td = el.parent().next().find('td').eq(0)
								pack.doc_number = td.text()
								pack.date = td.next().text()
						html.find('td').each ->
							el = $(@)
							if el.text() is 'Но- мер'
								row = el.parent().next().next()
								index = {}
								pos = 0
								row.find('td').each ->
									el = $ @
									colspan = el.attr 'colspan'
									if colspan
										clsp = parseInt colspan
										pos += clsp
									else
										clsp = 1
										pos += 1
									switch el.text()
										when "2"
											index.name = pos - clsp
										when "3"
											index.product_name_article = pos - clsp
										when "8"
											index.amount = pos - clsp
										when "11"
											index.price = pos - clsp
								row = row.next()
								cells = row.find 'td'
								while parseInt cells.eq(0).text()
									cur = 0
									push = {}
									row.find('td').each ->
										el = $ @
										colspan = el.attr 'colspan'
										if colspan
											clsp = parseInt colspan
											cur += clsp
										else
											clsp = 1
											cur += 1
										find = cur - clsp
										if find is index.name
											push.name = el.text()
										else if find is index.product_name_article
											push.product_name_article = el.text()
										else if find is index.amount
											push.amount = parseInt el.text()
										else if find is index.price
											price = parseFloat el.text().replace(' ', '').replace ',','.'
											if price
												push.price = price
											else
												push.price = parseFloat el.next().text().replace(' ', '').replace ',','.'
									unless push.amount
										cur = 0
										row.find('td').each ->
											el = $ @
											colspan = el.attr 'colspan'
											if colspan
												clsp = parseInt colspan
												cur += clsp
											else
												clsp = 1
												cur += 1
											find = cur - clsp + 1
											if find is index.amount
												push.amount = parseInt el.text()
									items.push push
									row = row.next()
									cells = row.find 'td'
						if items.length
							post "packinglist/create", {pack: pack, items: items}, (d) ->
								notify "Накладная сохранена"
								pack.id = d.pack_id
								items_price = 0
								amount = 0
								all_products = true
								for item, i in items
									item.id = d.item_ids[i]
									item.product_id = d.product_ids[i]
									all_products = false unless d.product_ids[i]
									item.product_name_article = d.product_scodes[i] if d.product_scodes[i]
									items_price += item.price * (amount += item.amount)
								ret = "<tr data-id='#{pack.id}'>
									<td class='btn always "
								if all_products
									ret += "green"
								else
									ret += "red"
								ret += "'>#{pack.date}</td>
									<td>#{pack.doc_number}</td>
									<td>#{items_price.toCurrency()} руб.</td>
									<td>#{amount}</td>
									<td><a class='btn blue' href='/admin/model/packinglist/edit/#{pack.id}' onclick='app.click(this)'>Открыть</a></td>
									<td class='btn red' onclick='packinglist_destroy(this)'>Удалить</td>
								</tr>"
								$('#packinglistTable').append ret
								total_price = $ '#total_price'
								total_price.html (parseFloat(total_price.html().replace(' ', '')) + items_price).toCurrency() + ' руб.'
						else
							notify 'Не найдены товары в накладной'
					reader.readAsText f
		packinglist_destroy: (el, id) ->
			tr = $(el).parent().eq(0).attr 'id', 'removeRecord'
			ask "Удалить запись?",
				ok:
					html: "Удалить"
					class: "red"
				action: ->
					tr = $('#removeRecord').attr 'id', ''
					id = tr.data 'id'
					db.destroy 'packinglist', id, ->
						tr.remove()
				cancel: -> $('#removeRecord').attr 'id', ''