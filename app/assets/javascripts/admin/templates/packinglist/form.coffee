app.templates.form.packinglist =
	page: ->
		price = 0
		pack = window.rec
		items = db.where 'packinglistitem', packinglist_id: param.id
		price += r.price * r.amount for r in items
		ret = "<div class='header'>
			<div class='top'>
				<div>
					<div class='name'>Товарная накладная</div>
				</div>
			</div>
		</div>
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
			tp = $.extend true, {}, packinglist_tree_params
			if item.product_id
				tp.treeboxAttrs.class += ' green'
				tp.input.value = item.product_id
				tp.rec = db.find('product', item.product_id)[0]
			else
				tp.treeboxAttrs.class += ' red'
				tp.header = item.product_name_article
			ret += "<tr data-id='#{item.id}'>#{treebox.gen tp}<td><p class='name'>#{item.name}</p></td>
				<td style='width: 1%'><input onkeyup='packinglist_price(this)' style='text-align: center' type='text' name='amount' value='#{item.amount}'></td>
				<td style='width: 12%'><input onkeyup='packinglist_price(this)' style='text-align: center' type='text' name='price' value='#{item.price.toCurrency() + ' руб.'}'></td>
				<td style='width: 15%'><p>#{(item.price * item.amount).toCurrency()} руб.</p></td>
				<td class='btn green' onclick='packinglist_update(this)'>Сохранить</td>
				<td class='btn red' onclick='packinglist_destroy(this)'>Удалить</td>
			</tr>"
		ret + "</table><br><div class='btn blue' onclick='packinglist_add(this)'>Добавить новую запись</div><br><br></form></div>"
	has_many: [model: 'packinglistitem', belongs_to: ['product']]
	after: -> treebox.out_click()
	functions:
		packinglist_tree_params:
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
		packinglist_price: (el) ->
			form = $(el).parents 'form'
			price = 0
			form.find("[name='price']").each ->
				el = $ @
				td = el.parents('td')
				itemPrice = parseFloat(el.val().replace(' ', '')) * parseInt(td.prev().find('input').val())
				td.next().html itemPrice.toCurrency() + ' руб.'
				price += itemPrice
			form.find('#end-price').html price.toCurrency() + ' руб.'
		packinglist_add: (el) ->
			tp = $.extend true, {}, packinglist_tree_params
			tp.treeboxAttrs.class += ' red'
			tp.header = "Выберите товар"
			tp.input.name = "product_id"
			tp.cb =
				pick: (params) ->
					params.treebox.removeClass('red').addClass('green').next().find('input').val db.product.records[params.el.data('val')].title
			$(el).parent().find('table').append "<tr class='add_items'>
				#{treebox.gen tp}
				<td><input type='text' name='name'></td>
				<td style='width: 10%'><input onkeyup='packinglist_price(this)' style='text-align: center' type='text' name='amount' value='1'></td>
				<td style='width: 10%'><input onkeyup='packinglist_price(this)' style='text-align: center' type='text' name='price' value='0'></td>
				<td style='width: 15%'>0</td>
				<td class='btn green' onclick='packinglist_create(this)'>Создать</td>
				<td class='btn red' onclick='$(this).parent().remove()'>Удалить</td>
			</tr>"
			treebox.out_click()
		packinglist_create: (el) ->
			el = $ el
			tr = el.parent()
			product_id = tr.find("[name='product_id']").val()
			name = tr.find("[name='name']").val()
			amount = parseInt tr.find("[name='amount']").val()
			price = parseFloat tr.find("[name='price']").val().replace(' ', '')
			db.create_one 'packinglistitem', {packinglist_id: param.id, name: name, product_id: product_id, amount: amount, price: price}, (id) ->
				tr.data('id', id).find("[name='price']").val(price.toCurrency() + ' руб.')
				el.attr('onclick', 'packinglist_update(this)').next().attr('onclick', 'packinglist_destroy(this)')
				notify 'Товар добавлен к накладной'
		packinglist_update: (el) ->
			tr = $(el).parent()
			id = tr.data 'id'
			product_id = tr.find("[name='product_id']").val()
			name = tr.find(".name").html()
			amount = tr.find("[name='amount']").val()
			price = parseFloat(tr.find("[name='price']").val().replace(' ',''))
			db.update_one 'packinglistitem', id, {product_id: product_id, name: name, amount: amount, price: price}, ->
				notify 'Товар накладной успещно обновлен'
		packinglist_destroy: (el) ->
			tr = $(el).parent().attr 'id', 'removeRecord'
			ask "Удалить запись?",
				ok:
					html: "Удалить"
					class: "red"
				action: ->
					tr = $('#removeRecord').attr 'id', ''
					id = tr.data 'id'
					db.destroy 'packinglistitem', id, ->
						tr.remove()
				cancel: -> $('#removeRecord').attr 'id', ''