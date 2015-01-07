app.page = ->
	ret = "<h1>Товарные накладные</h1>
	<div class='content'>
		<div>
			<br>
			<input type='file'><div class='btn deepblue'>Загрузить</div>
			<br>
			<br>
			<table>
				<tr>
					<th>Дата/Статус</th>
					<th>№ Накладной</th>
					<th>Сумма</th>
					<th>Общее кол-во товаров</th>
					<th>Действия</th>
				</tr>"
	for rec in tables['packinglist'].records
		pack = rec.record
		items = []
		for rec in tables['packinglistitem'].records
			if rec.record.packinglist_id is pack.id
				items.push rec.record
		color = '#54BD48'
		price = count = 0
		for item in items
			if !item.product_id
				color = '#DB4343'
			price += item.price * item.amount
			count += item.amount
		ret += "<tr>
					<td style='color: white; background-color: #{color}'>
						<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{pack.date}</a>
					</td>
					<td>
						<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{pack.number || "id: #{pack.id}"}</a>
					</td>
					<td>
						<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{price}</a>
					</td>
					<td>
						<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{count}</a>
					</td>
					<td class='btn red' onclick='record.destroy(this, \"packinglist\", #{pack.id})'>Удалить</td>
				</tr>"
	ret += "</table>
			<br>
		</div>
	</div>"
	ret