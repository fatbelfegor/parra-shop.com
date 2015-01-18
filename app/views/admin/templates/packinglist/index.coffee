@packinglist =
	upload: (el) ->
		form = $(el).parent()
		formData = new FormData()
		formData.append "file", form.find('input')[0].files[0]
		$.ajax
			url: "/admin/packinglist/upload"
			type: "POST"
			data: formData
			dataType: 'json'
			processData: false
			contentType: false
			success: (d) ->
				act.notify "Товарная накладная загружена"
				ret = ""
				for pack in d.packinglist
					items = []
					for rec in d.packinglistitem
						if rec.packinglist_id is pack.id
							items.push rec
					color = '#54BD48'
					price = count = 0
					for item in items
						if !item.product_id
							color = '#DB4343'
						price += item.price * item.amount
						count += item.amount
					ret += "<tr data-model='packinglist' data-id='#{pack.id}'>
								<td style='color: white; background-color: #{color}'>
									<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{pack.date}</a>
								</td>
								<td>
									<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{pack.doc_number || "id: #{pack.id}"}</a>
								</td>
								<td>
									<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{price}</a>
								</td>
								<td>
									<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{count}</a>
								</td>
								<td class='btn red' onclick='record.btnDestroy(this)'>Удалить</td>
							</tr>"
				form.next().find('#packinglist-after').after ret
app.page = ->
	"<h1>Товарные накладные</h1>
	<div class='content'>
		<div>
			<form>
				<br>
				<input type='file'><div class='btn deepblue' onclick='packinglist.upload(this)'>Загрузить</div>
				<br>
				<br>
			</form>
			<table>
				<tr id='packinglist-after'>
					<th>Дата/Статус</th>
					<th>№ Накладной</th>
					<th>Сумма</th>
					<th>Общее кол-во товаров</th>
					<th>Действия</th>
				</tr id='packinglist-after'>
			</table>
			<br>
		</div>
	</div>"
app.after = ->
	record.ask {model: 'packinglist', has_many: ['packinglistitem']}, ->
		ret = ""
		for rec in tables['packinglist'].records
			pack = rec
			items = []
			for rec in tables['packinglistitem'].records
				if rec.packinglist_id is pack.id
					items.push rec
			color = '#54BD48'
			price = count = 0
			for item in items
				if !item.product_id
					color = '#DB4343'
				price += item.price * item.amount
				count += item.amount
			ret += "<tr data-model='packinglist' data-id='#{pack.id}'>
						<td style='color: white; background-color: #{color}'>
							<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{pack.date}</a>
						</td>
						<td>
							<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{pack.doc_number || "id: #{pack.id}"}</a>
						</td>
						<td>
							<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{price}</a>
						</td>
						<td>
							<a href='/admin/packinglist/#{pack.id}' onclick='app.aclick(this)'>#{count}</a>
						</td>
						<td class='btn red' onclick='record.btnDestroy(this)'>Удалить</td>
					</tr>"
		$('#packinglist-after').after ret