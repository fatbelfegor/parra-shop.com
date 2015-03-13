@packshow =
	save_cb: (d) ->
		form = $ 'form'
		form.find("[name='items[]id']").each ->
			el = $ @
			tr = el.parent()
			id = parseInt el.val()
			rec = record.find 'packinglistitem', id
			product_id = parseInt tr.find("[name='items[]product_id']").val()
			rec.product_id = product_id if product_id
			amount = parseInt tr.find("[name='items[]amount']").val()
			rec.amount = amount if amount
			price = parseFloat tr.find("[name='items[]price']").val()
			rec.price = price if price
		for tr, i in form.find ".add_items"
			tr = $ tr
			tr.removeClass 'add_items'
			product_id = parseInt(tr.find("[name='add_items[]product_id']").attr('name', 'items[]product_id').val()) || null
			amount = parseInt(tr.find("[name='add_items[]amount']").attr('name', 'items[]amount').val()) || 1
			price = parseFloat(tr.find("[name='add_items[]price']").attr('name', 'items[]price').val()) || 0
			product_name_article = tr.find "[name='add_items[]product_name_article']"
			name = tr.find "[name='add_items[]name']"
			tables.packinglistitem.records.push
				id: d.item_ids[i]
				product_id: product_id
				product_name_article: product_name_article.val()
				name: name.val()
				amount: amount
				price: price
				packinglist_id: parseInt(form.find("[name='packinglist_id']").val())
			delete treebox.cb[product_name_article.parents('.treebox').data 'index'].header
			product_name_article.remove()
			name.parent().html "<p>#{name.val()}</p>"
			tr.find("td:last-child").attr('onclick', "packshow.destroy(this, #{d.item_ids[i]})").after "<input type='hidden' name='items[]id' value='#{d.item_ids[i]}'>"
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
		tp = $.extend true, {}, @tree_params
		tp.classes[1] = 'red'
		tp.header = "Выберите товар"
		tp.input.name = "add_items[]product_id"
		tp.cb.header = (params) ->
			html = params.header.html()
			params.header.html html + "<input type='hidden' name='add_items[]product_name_article' value='#{html}'>"
		$(el).parent().find('table').append "<tr class='add_items'>
			#{treebox.gen tp}
			<td><input type='text' name='add_items[]name'></td>
			<td style='width: 10%'><input onkeyup='packshow.price(this)' style='text-align: center' type='text' name='add_items[]amount' value='1'></td>
			<td style='width: 10%'><input onkeyup='packshow.price(this)' style='text-align: center' type='text' name='add_items[]price' value='0'></td>
			<td style='width: 15%'>0</td>
			<td class='btn red' onclick='$(this).parent().remove()'>Удалить</td>
		</tr>"
		treebox.out_click()
	destroy: (el, id) ->
		ask 'Удалить товар из накладной?', (options) ->
			record.destroy 'packinglistitem', options.id
			$(options.el).parents('tr').remove()
		, el: el, id: id
	tree_params:
		tag: 'td'
		input:
			name: 'items[]product_id'
		classes: ['btn', '', 'always']
		data:
			category:
				fields: ['name']
				has_self: true
				habtm:
					product:
						fields: ['name']
						pick: true
						group: 'Товары'
		pick:
			val: 'id'
			header: 'scode'
		cb: 
			pick: (params) ->
				params.treebox.removeClass('red').addClass 'green'

app.preload = ->
	model: 'packinglist', has_many: {model: 'packinglistitem', belongs_to: {model: 'product'}}
app.page = (recs) ->
	price = 0
	pack = models.packinglist.find param.id
	items = pack.packinglistitems()
	price += r.price * r.amount for r in items
	ret = "<h1>Товарная накладная</h1>
	<div class='content'>
		<br>
		<form action='packinglist/update'>
			<input type='hidden' name='packinglist_id' value='#{pack.id}'>
			<div class='btn green dashed' onclick='btn_send(this, \"Товарная накладная обновлена\", packshow.save_cb)'>Сохранить</div>
			<br>
			<br>
			<div class='row'>
				<p>Номер: #{pack.doc_number}</p>
				<p>Дата: #{pack.date}</p>
				<p>Общая сумма: <span id='end-price'>#{price}</span></p>
			</div>
			<br>
			<table class='style'>
				<tr>
					<th>Код</th>
					<th>Название товара</th>
					<th>Количество</th>
					<th>Цена (руб.)</th>
					<th>Итоговая цена (руб.)</th>
					<th></th>
				</tr>"
	for item in items
		tp = $.extend true, {}, packshow.tree_params
		if item.product_id
			tp.classes[1] = 'green'
			tp.input.value = item.product_id
			tp.rec = models.product.find item.product_id
		else
			tp.classes[1] = 'red'
			tp.header = item.product_name_article
		ret += "<tr>#{treebox.gen tp}<td><p>#{item.name}</p></td>
			<td style='width: 10%'><input onkeyup='packshow.price(this)' style='text-align: center' type='text' name='items[]amount' value='#{item.amount}'></td>
			<td style='width: 10%'><input onkeyup='packshow.price(this)' style='text-align: center' type='text' name='items[]price' value='#{item.price}'></td>
			<td style='width: 15%'><p>#{item.price * item.amount}</p></td>
			<td class='btn red' onclick='packshow.destroy(this, #{item.id})'>Удалить</td>
			<input type='hidden' name='items[]id' value='#{item.id}'>
		</tr>"
	ret += "</table>
			<br>
			<div class='btn blue' onclick='packshow.add(this)'>Добавить новую запись</div>
			<br><br>
			<a class='btn purple' href='/products/new'>Создать товар</a>
			<br><br>
		</form>
	</div>"
	ret
app.after = ->
	treebox.out_click()