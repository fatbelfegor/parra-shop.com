app.functions =
	price: (el) ->
		form = $(el).parents 'form'
		price = 0
		form.find("[name='price']").each ->
			el = $ @
			td = el.parents('td')
			itemPrice = parseFloat(el.val().replace(' ', '')) * parseInt(td.prev().find('input').val())
			td.next().html itemPrice.toCurrency() + ' руб.'
			price += itemPrice
		form.find('#end-price').html price.toCurrency() + ' руб.'
	add: (el) ->
		tp = $.extend true, {}, @tree_params
		tp.treeboxAttrs.class += ' red'
		tp.header = "Выберите товар"
		tp.input.name = "product_id"
		tp.cb =
			pick: (params) ->
				params.treebox.removeClass('red').addClass('green').next().find('input').val models.product.collection[params.el.data('val')].title
		$(el).parent().find('table').append "<tr class='add_items'>
			#{treebox.gen tp}
			<td><input type='text' name='name'></td>
			<td style='width: 10%'><input onkeyup='functions.price(this)' style='text-align: center' type='text' name='amount' value='1'></td>
			<td style='width: 10%'><input onkeyup='functions.price(this)' style='text-align: center' type='text' name='price' value='0'></td>
			<td style='width: 15%'>0</td>
			<td class='btn green' onclick='functions.create(this)'>Создать</td>
			<td class='btn red' onclick='$(this).parent().remove()'>Удалить</td>
		</tr>"
		treebox.out_click()
	create: (el) ->
		el = $ el
		tr = el.parent()
		product_id = tr.find("[name='product_id']").val()
		name = tr.find("[name='name']").val()
		amount = parseInt tr.find("[name='amount']").val()
		price = parseFloat tr.find("[name='price']").val().replace(' ', '')
		data = {relation: [{model: 'packinglistitem', new_records: [fields: {packinglist_id: param.id, name: name, product_id: product_id, amount: amount, price: price}]}]}
		formData =  new FormData()
		formData.append "relation[0]model", 'packinglistitem'
		formData.append "relation[0]new_records[0]fields[packinglist_id]", param.id
		formData.append "relation[0]new_records[0]fields[product_id]", product_id
		formData.append "relation[0]new_records[0]fields[name]", name
		formData.append "relation[0]new_records[0]fields[price]", price
		formData.append "relation[0]new_records[0]fields[amount]", amount
		record.save data, formData: formData, cb: (res) ->
			tr.data('id', res.relation[0].new_records[0].record.id).find("[name='price']").val(price.toCurrency() + ' руб.')
			el.attr('onclick', 'functions.update(this)').next().attr('onclick', 'functions.destroy(this)')
	update: (el) ->
		tr = $(el).parent()
		id = tr.data 'id'
		product_id = tr.find("[name='product_id']").val()
		name = tr.find(".name").html()
		amount = tr.find("[name='amount']").val()
		price = parseFloat(tr.find("[name='price']").val().replace(' ',''))
		data = {relation: [{model: 'packinglistitem', update_records: [id: id, fields: {product_id: product_id, name: name, amount: amount, price: price}]}]}
		formData =  new FormData()
		formData.append "relation[0]model", 'packinglistitem'
		formData.append "relation[0]update_records[0]id", id
		formData.append "relation[0]update_records[0]fields[product_id]", product_id
		formData.append "relation[0]update_records[0]fields[name]", name
		formData.append "relation[0]update_records[0]fields[amount]", amount
		formData.append "relation[0]update_records[0]fields[price]", price
		record.save data, formData: formData
	destroy: (el) ->
		tr = $(el).parent().attr 'id', 'removeRecord'
		ask "Удалить запись?",
			ok:
				html: "Удалить"
				class: "red"
			action: ->
				tr = $('#removeRecord').attr 'id', ''
				id = tr.data 'id'
				$.ajax
					url: "/admin/model/packinglistitem/destroy/#{id}"
					type: 'POST'
					contentType: false
					processData: false
					dataType: "json"
					success: (res) ->
						if res is 'permission denied'
							notify 'Доступ запрещен', class: 'red'
						else
							tr.remove()
							delete models['packinglistitem'].collection[id]
							notify "Запись удалена"
			cancel: -> $('#removeRecord').attr 'id', ''
	tree_params:
		tag: 'td'
		input:
			name: 'product_id'
		treeboxAttrs:
			class: 'btn always'
		data:
			category:
				fields: ['name']
				has_self: true
				habtm:
					product:
						fields: ['name', 'title']
						pick: true
						group: 'Товары'
		pick:
			val: 'id'
			header: 'title'
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
		<form>
			<br>
			<div class='row'>
				<p>Номер: #{pack.doc_number}</p>
				<p>Дата: #{pack.date}</p>
				<p>Общая сумма: <span id='end-price'>#{price.toCurrency()} руб.</span></p>
			</div>
			<br>
			<table class='style'>
				<tr>
					<th>Код</th>
					<th>Название товара</th>
					<th>Количество</th>
					<th>Цена</th>
					<th>Итоговая цена</th>
					<th colspan='2'>Действия</th>
				</tr>"
	for item in items
		tp = $.extend true, {}, functions.tree_params
		if item.product_id
			tp.treeboxAttrs.class += ' green'
			tp.input.value = item.product_id
			tp.rec = models.product.find item.product_id
		else
			tp.treeboxAttrs.class += ' red'
			tp.header = item.product_name_article
		ret += "<tr data-id='#{item.id}'>#{treebox.gen tp}<td><p class='name'>#{item.name}</p></td>
			<td style='width: 1%'><input onkeyup='functions.price(this)' style='text-align: center' type='text' name='amount' value='#{item.amount}'></td>
			<td style='width: 12%'><input onkeyup='functions.price(this)' style='text-align: center' type='text' name='price' value='#{item.price.toCurrency() + ' руб.'}'></td>
			<td style='width: 15%'><p>#{(item.price * item.amount).toCurrency()} руб.</p></td>
			<td class='btn green' onclick='functions.update(this)'>Сохранить</td>
			<td class='btn red' onclick='functions.destroy(this)'>Удалить</td>
		</tr>"
	ret += "</table>
			<br>
			<div class='btn blue' onclick='functions.add(this)'>Добавить новую запись</div>
			<br><br>
		</form>
	</div>"
	ret
app.after = ->
	treebox.out_click()