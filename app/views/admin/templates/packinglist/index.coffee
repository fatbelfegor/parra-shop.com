@packindex =
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
					html.find('td > p').each ->
						el = $(@)
						if el.text() is 'Но- мер'
							row = el.parent().parent().next().next().next()
							while row.find('td').eq(0).html() isnt '&nbsp;'
								cols = []
								row.find('td').each ->
									td = $ @
									cols.push td.text() if @innerHTML isnt "&nbsp;" or td.attr('class') not in ['ce1', 'ce5', 'ce27', 'ce30', 'Default']
								items.push name: cols[1], product_name_article: cols[2], amount: parseInt(cols[7]), price: parseFloat(cols[10])
								row = row.next()
					send "packinglist/create", {pack: pack, items: items}, "Накладная сохранена", (d) ->
						console.log items
						pack.id = d.pack_id
						tables['packinglist'].records.push pack
						items_price = 0
						amount = 0
						for item, i in items
							item.id = d.item_ids[i]
							item.product_id = d.product_ids[i]
							item.product_name_article = d.product_scodes[i] if d.product_scodes[i]
							items_price += item.price * (amount += item.amount)
						tables['packinglistitem'].records = tables['packinglistitem'].records.concat items
						ret = "<tr>
							<td class='btn always "
						if pack.product_id
							ret += "green"
						else
							ret += "red"
						ret += "'>#{pack.date}</td>
							<td>#{pack.doc_number}</td>
							<td>#{items_price}</td>
							<td>#{amount}</td>
							<td><a href='/admin/packinglist/#{pack.id}' onclick='app.click(this)' class='btn blue'>Открыть</a></td>
							<td><div class='btn red' onclick='packindex.destroy(this, #{pack.id})'>Удалить</div></td>
						</tr>"
						$('#packinglistTable').append ret
						total_price = $ '#total_price'
						total_price.html parseFloat(total_price.html()) + items_price
				reader.readAsText f
	destroy: (el, id) ->
		ask 'Удалить накладную?', (options) ->
			record.destroy 'packinglist', options.id
			$(options.el).parents('tr').remove()
		, el: el, id: id
app.page = ->
	packs = ""
	price = 0
	for pack in tables['packinglist'].records
		items_price = 0
		amount = 0
		price += items_price += item.price * (amount += item.amount) for item in tables['packinglistitem'].records
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
					<td><div class='row'><p>Общая стоимость: <span id='total_price'>#{price}</span> руб.</p></div></td>
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