
@packinglist =
	treebox: (el) ->
		treebox.toggle el
		el = $ el
		ul = el.parent().next()
		if ul.html() is ''
			id = el.data 'id'
			cats = []
			for rec in tables.category.records
				if rec.record.parent_id is id
					cats.push rec
				else if rec.record.id is id
					thisCat = rec
			ret = ''
			for cat in cats
				ret += "<li>"
				if cat.children > 0 or cat.habtm.products.length > 0
					ret += "<div><i class='icon-arrow-down2' onclick='packinglist.treebox(this)' data-id='#{cat.record.id}'></i><p>#{cat.record.name}</p></div><ul></ul>"
				else
					ret += "<div><p>#{cat.record.name}</p></div>"
				ret += "</li>"
			ids = thisCat.habtm.products
			if ids.length > 0
				products = []
				for rec in tables.product.records
					if rec.record.id in ids
						products.push rec
				for product in products
					ret += "<li><div><p onclick='packinglist.pick(this)' data-id='#{product.record.id}'>#{product.record.scode}</p></div></li>"
			ul.html ret
	pick: (el) ->
		el = $ el
		tb = el.parents('.treebox').removeClass('active').css 'background-color', '#54BD48'
		tb.find('input').val el.data 'id'
		tb.find('> p').html el.html()
	price: (el) ->
		form = $(el).parents 'form'
		price = 0
		form.find("[name='items[]price'], [name='add_items[]price']").each ->
			el = $ @
			td = el.parents('td')
			itemPrice = parseFloat(el.val()) * parseInt(td.prev().find('input').val())
			td.next().html itemPrice
			price += itemPrice
		form.find('#end-price').html price
	add: (el) ->
		$(el).parent().find('table').append "<tr>
			<td style='color: white; background-color: #DB4343; cursor: pointer; white-space: nowrap' class='treebox' id='treebox_packinglist'>
				<p onclick='treebox.toggle(this)'><span>Выберите товар</span></p>
				<ul style='color: #333; width: 400px'>#{packinglist.tree}</ul>
				<input type='hidden' data-type='integer' name='add_items[]product_id'>
			</td>
			<td><input type='text' name='add_items[]name'></td>
			<td style='width: 10%'><input onkeyup='packinglist.price(this)' style='text-align: center' type='text' name='add_items[]amount' value='1'></td>
			<td style='width: 10%'><input onkeyup='packinglist.price(this)' style='text-align: center' type='text' name='add_items[]price' value='0'></td>
			<td style='width: 15%'>0</td>
		</tr>"
		packinglist.tree_out_click()
	tree_out_click: ->
		$('html').click ->
			$('.treebox').removeClass 'active'
		$('.treebox').click (event) ->
		    event.stopPropagation()
app.page = ->
	id = parseInt app.data.route.id
	for rec in tables['packinglist'].records
		if rec.record.id is id
			pack = rec.record
	items = []
	price = 0
	for rec in tables['packinglistitem'].records
		item = rec.record
		if item.packinglist_id is pack.id
			items.push item
			price += item.price * item.amount
	ret = "<h1>Товарная накладная</h1>
	<div class='content'>
		<form action='packinglist/update'>
			<input type='hidden' name='packinglist_id' value='#{pack.id}'>
			<div class='btn green dashed' onclick='act.send(this, \"Товарная накладная обновлена\")'>Сохранить</div>
			<br>
			<div class='row'>
				<p>Номер: #{pack.doc_number}</p>
				<p>Дата: #{pack.date}</p>
				<p>Общая сумма: <span id='end-price'>#{price}</span></p>
			</div>
			<br>
			<table>
				<tr>
					<th>Код</th>
					<th>Название товара</th>
					<th>Количество</th>
					<th>Цена (руб.)</th>
					<th>Итоговая цена (руб.)</th>
				</tr>"
	cats = []
	for rec in tables.category.records
		if !rec.record.parent_id
			cats.push rec
	packinglist.tree = ''
	for cat in cats
		packinglist.tree += "<li>"
		if cat.children > 0 or cat.habtm.products.length > 0
			packinglist.tree += "<div><i class='icon-arrow-down2' onclick='packinglist.treebox(this)' data-id='#{cat.record.id}'></i><p>#{cat.record.name}</p></div><ul></ul>"
		else
			packinglist.tree += "<div><p>#{cat.record.name}</p></div>"
		packinglist.tree += "</li>"
	for item in items
		color = '#54BD48'
		if !item.product_id
			color = '#DB4343'
		ret += "<tr>
			<input type='hidden' name='items[]id' value='#{item.id}'>
			<td style='color: white; background-color: #{color}; cursor: pointer; white-space: nowrap' class='treebox' id='treebox_packinglist'>
				<p onclick='treebox.toggle(this)'><span>#{item.product_name_article}</span></p>
				<ul style='color: #333; width: 400px'>#{packinglist.tree}</ul>
				<input type='hidden' data-type='integer' name='items[]product_id'>
			</td>
			<td>#{item.name}</td>
			<td style='width: 10%'><input onkeyup='packinglist.price(this)' style='text-align: center' type='text' name='items[]amount' value='#{item.amount}'></td>
			<td style='width: 10%'><input onkeyup='packinglist.price(this)' style='text-align: center' type='text' name='items[]price' value='#{item.price}'></td>
			<td style='width: 15%'>#{item.price}</td>
		</tr>"
	ret += "</table>
			<br>
			<div class='btn deepblue' onclick='packinglist.add(this)'>Добавить новую запись</div>
			<br>
			<div class='btn green dashed' onclick='act.send(this, \"Товарная накладная обновлена\")'>Сохранить</div>
		</form>
	</div>"
	ret
app.after = ->
	packinglist.tree_out_click()