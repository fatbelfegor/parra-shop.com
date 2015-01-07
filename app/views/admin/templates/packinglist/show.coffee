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
			<div class='btn green dashed' onclick='act.send(this, \"Товарная накладная обновлена\")'>Сохранить</div>
			<br>
			<div class='row'>
				<p>Номер: #{pack.doc_number}</p>
				<p>Дата: #{pack.date}</p>
				<p>Общая сумма: #{price}</p>
			</div>
			<br>
			<table>
				<tr>
					<th>Код</th>
					<th>Название товара</th>
					<th>Количество</th>
					<th>Цена (руб.)</th>
				</tr>"
	for item in items
		color = '#54BD48'
		if !item.product_id
			color = '#DB4343'
		ret += "<tr>
			<input type='hidden' name='items[]id' value='#{item.id}'>
			<td style='color: white; background-color: #{color}'>#{item.product_name_article}</td>
			<td>#{item.name}</td>
			<td style='width: 10%'><input style='text-align: center' type='text' name='items[]amount' value='#{item.amount}'></td>
			<td style='width: 10%'><input style='text-align: center' type='text' name='items[]price' value='#{item.price}'></td>
		</tr>"
	ret += "</table>
			<div class='btn green dashed' onclick='act.send(this, \"Товарная накладная обновлена\")'>Сохранить</div>
		</form>
	</div>"
	ret