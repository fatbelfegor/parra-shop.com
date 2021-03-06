window.packindex =
	upload: (input) ->
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
					html.find('td:first-child').each ->
						el = $(@)
						next = el.parent().next()
						if el.text() is 'Но- мер' and next.find('td:first-child').text() is 'по по- ряд- ку'
							row = next.next().next()
							firstChildHtml = row.find('td:first-child').text()
							while parseInt firstChildHtml
								cols = []
								console.log parseInt(firstChildHtml)
								row.find('td').each ->
									td = $ @
									cols.push td.text() if @innerHTML isnt "&nbsp;" or td.attr('class') not in ['ce1', 'ce5', 'ce23', 'ce27', 'ce30', 'ce31', 'Default']
								items.push name: cols[1], product_name_article: cols[2], amount: parseInt(cols[7]), price: parseFloat(cols[10].replace(' ', '').replace(',','.'))
								row = row.next()
								firstChildHtml = row.find('td:first-child').text()
					console.log items
					# post "packinglist/create", {pack: pack, items: items}, (d) ->
					# 	pack.id = d.pack_id
					# 	models.packinglist.collect pack
					# 	items_price = 0
					# 	amount = 0
					# 	model = models.packinglistitem
					# 	for item, i in items
					# 		item.id = d.item_ids[i]
					# 		item.product_id = d.product_ids[i]
					# 		item.product_name_article = d.product_scodes[i] if d.product_scodes[i]
					# 		items_price += item.price * (amount += item.amount)
					# 		model.collect item
					# 	ret = "<tr>
					# 		<td class='btn always "
					# 	if pack.product_id
					# 		ret += "green"
					# 	else
					# 		ret += "red"
					# 	ret += "'>#{pack.date}</td>
					# 		<td>#{pack.doc_number}</td>
					# 		<td>#{items_price}</td>
					# 		<td>#{amount}</td>
					# 		<td><a href='/admin/packinglist/#{pack.id}' onclick='app.click(this)' class='btn blue'>Открыть</a></td>
					# 		<td><div class='btn red' onclick='packindex.destroy(this, #{pack.id})'>Удалить</div></td>
					# 	</tr>"
					# 	$('#packinglistTable').append ret
					# 	total_price = $ '#total_price'
					# 	total_price.html parseFloat(total_price.html()) + items_price
					# 	notify "Накладная сохранена"
				reader.readAsText f
	destroy: (el, id) ->
		ask 'Удалить накладную?', (options) ->
			pack = models.packinglist.find options.id
			for item in pack.packinglistitems
				post "model/packinglistitem/destroy/" + item.id
			post "model/packinglist/destroy/" + options.id
			$(options.el).parents('tr').remove()
		, el: el, id: id
app.preload = ->
	{model: 'packinglist', has_many: {model: 'packinglistitem'}}
app.page = ->
	packinglists = models.packinglist.all()
	packs = ""
	price = 0
	for pack in packinglists
		items_price = 0
		amount = 0
		price += items_price += item.price * (amount += item.amount) for item in pack.packinglistitems()
		packs += "<tr>
			<td class='btn always "
		if pack.product_id
			packs += "green"
		else
			packs += "red"
		packs += "'>#{pack.date}</td>
			<td>#{pack.doc_number}</td>
			<td>#{items_price}</td>
			<td>#{amount}</td>
			<td><a href='/admin/packinglist/#{pack.id}' onclick='app.click(this)' class='btn blue'>Открыть</a></td>
			<td><div class='btn red' onclick='packindex.destroy(this, #{pack.id})'>Удалить</div></td>
		</tr>"
	"<h1>Товарные накладные</h1>
	<div class='content'>
		<label class='text-center'><div class='btn blue ib m15'>Выбрать файл накладной (HTML)</div><div class='hide'></div><input class='hide' onchange='packindex.upload(this)' type='file' multiple></label>
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