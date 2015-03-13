@model = {}
app.page = ->
	ret = "<h1>Создать новую модель</h1>
	<div class='content'>
		<form action='model/create'>
			<div class='btn green m15' onclick='model.create(this)'>Создать</div>
			<label class='row m0auto' style='width: 300px'><p>Название</p><input type='text' name='model'></label>
			<br>
			<div class='nav-tabs'>
				<p onclick='openTab(this)' class='active'>Поля</p>
				<p onclick='openTab(this)'>belongs_to</p>
				<p onclick='openTab(this)'>has_many</p>
				<p onclick='openTab(this)'>has_one</p>
			</div>
			<div class='tabs'>
				<div class='active'>
					<table class='style' id='model-table'>
						<tr>
							<th>Type</th>
							<th>Name</th>
							<th>Limit</th>
							<th>Precision</th>
							<th>Scale</th>
							<th>Default</th>
							<th>Index</th>
							<th>Uniq</th>
							<th>Null</th>
							<th></th>
							<th></th>
						</tr>
					</table>
					<br>
					<div>
						<div class='btn green' onclick='functions.addColumn()'>Добавить поле</div>
						<div class='btn white' onclick='functions.addColumn(\"name\")'>Название</div>
						<div class='btn white' onclick='functions.addColumn(\"scode\")'>Код</div>
						<div class='btn white' onclick='functions.addColumn(\"article\")'>Артикул</div>
						<div class='btn white' onclick='functions.addColumn(\"short_desc\")'>Краткое описание</div>
						<div class='btn white' onclick='functions.addColumn(\"description\")'>Описание</div>
						<div class='btn white' onclick='functions.addColumn(\"price\")'>Цена</div>
						<div class='btn white' onclick='functions.addColumn(\"image\")'>Изображение</div>
						<div class='btn white' onclick='functions.addColumn(\"seo\")'>Seo</div>
						<div class='btn white' onclick='functions.addColumn(\"position\")'>Позиция</div>
					</div>
					<br>
					<div class='labels'>"
	for n of models
		if n is 'image'
			ret += "<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='imageable'></div>Множество картинок</label>"
			break
	ret += "<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='acts_as_tree'></div>Принадлежит сама себе</label>
						<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='timestamps'></div>Timestamps</label>
					</div>
					<br>
				</div>
				<div class='association-wrap' data-type='belongs_to'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n of models
		ret += "<div class='btn blue' onclick='model.association(this, true)'>#{n}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>
				<div class='association-wrap' data-type='has_many'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of models
		ret += "<div class='btn blue' onclick='model.association(this, true)'>#{table.pluralize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>
				<div class='association-wrap' data-type='has_one'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n of models
		ret += "<div class='btn blue' onclick='model.association(this, true)'>#{n}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>
				<!--<div class='association-wrap' data-type='has_and_belongs_to_many'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of models
		ret += "<div class='btn blue' onclick='model.association(this, true)'>#{table.singularize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>-->
			</div>
			<br>
		</form>
	</div>"
	ret
window.functions =
	create: (el) ->
		form = $(el).parent()
		validate form, ->
			data = form.serializeArray()
			name = form.find("[name='model']").val()
			fields = []
			$('.field').each ->
				if fields.length < 5
					el = $ @
					f_name = el.find("[name='addColumn[]name']").val()
					fields.push field: f_name if el.find("[name='addColumn[]type']").val() isnt 'Text' and f_name not in ['image', 'seo_title', 'seo_keywords', 'position']
			cols = []
			for f in fields
				cols.push "\n\t\t\t\t{\n\t\t\t\t\theader: '#{f.field}'\n\t\t\t\t\tfield: '#{f.field}'\n\t\t\t\t}"
			data.push name: 'index', value: "models.#{name.toLowerCase()}_index =\n\trows: [\n\t\t{\n\t\t\tcols: [#{cols.join ','},\n\t\t\t\t{\n\t\t\t\t\tbtn: 'edit'\n\t\t\t\t},\n\t\t\t\t{\n\t\t\t\t\tbtn: 'remove'\n\t\t\t\t}\n\t\t\t]\n\t\t}\n\t]"
			act.sendData form.attr('action'), data, "Модель успешно создана", (d) ->
				console.log d
	addColumn: (name) ->
		f = {type: 'String', name: '', limit: '', precision: '', scale: '', default: '', index: false, uniq: false, null: true}
		if name
			f.name = name
			switch name
				when 'name'
					f.null = false
				when 'scode'
					f.uniq = true
					f.index = true
					f.null = false
				when 'article'
					f.uniq = true
					f.index = true
				when 'short_desc', 'description', 'seo_description'
					f.type = 'Text'
				when 'price'
					f.type = 'Decimal'
					f.precision = 8
					f.scale = 2
				when 'seo'
					@addColumn 'seo_title'
					@addColumn 'seo_description'
					@addColumn 'seo_keywords'
				when 'position'
					f.type = 'Integer'
		ret = "<tr>
			<td>
				<div class='dropdown' onclick='dropdown.toggle(this)'>
					<p>String</p>
					<div>"
		for n in ['Binary', 'Boolean', 'Date', 'Datetime', 'Decimal', 'Float', 'Integer', 'Primary_key', 'String', 'Text', 'Time', 'Timestamp']
			ret += "<p#{if n is f.type then " class='active'" else ''} onclick='functions.dropdownPick(this)'>#{n}</p>"
		ret += "</div>
				</div>
			</td>
			<td><input type='text' name='name' value='#{f.name}'></td>
			<td><input type='text' name='limit' value='#{f.limit}'#{if f.type is 'Decimal' then ' disabled' else ''}></td>
			<td class='min'><input type='text' name='precision'#{if f.type is 'Decimal' then '' else ' disabled'} value='#{f.precision}'></td>
			<td class='min'><input type='text' name='scale'#{if f.type is 'Decimal' then '' else ' disabled'} value='#{f.scale}'></td>
			<td><input type='text' name='default' value='#{f.default}'></td>
			<td><label class='checkbox'><div#{if f.index then " class='checked'" else ''}><input#{if f.index then " checked='checked'" else ''} type='checkbox' name='index' onchange='checkbox(this)'></div></label></td>
			<td><label class='checkbox'><div#{if f.uniq then " class='checked'" else ''}><input#{if f.uniq then " checked='checked'" else ''} type='checkbox' name='uniq' onchange='functions.checkboxUniq(this)'></div></label></td>
			<td><label class='checkbox'><div#{if f.null then " class='checked'" else ''}><input#{if f.null then " checked='checked'" else ''} type='checkbox' name='null' onchange='checkbox(this)'></div></label></td>
			<td class='btn blue always'>Переместить</td>
			<td class='btn red always'>Удалить</td>
		</tr>"
		$('#model-table').append ret
	checkboxUniq: (el) ->
		checkbox el
		if el.checked
			c = $(el).parents('td').prev().find('input')[0]
			unless c.checked
				c.checked = true
				checkbox c

		# add: (el, name) ->
		# 	params =
		# 		name: ''
		# 		type: 'String'
		# 		precision: ''
		# 		scale: ''
		# 		null: true
		# 	if name
		# 		params.name = name
		# 	switch name
		# 		when 'scode'
		# 			params.uniq = true
		# 			params.null = false
		# 		when 'description'
		# 			params.type = 'Text'
		# 		when 'price'
		# 			params.type = 'Decimal'
		# 			params.precision = 8
		# 			params.scale = 2
		# 			params.null = false
		# 		when 'seo_description'
		# 			params.type = 'Text'
		# 		when 'seo'
		# 			@add el, 'seo_title'
		# 			@add el, 'seo_description'
		# 			@add el, 'seo_keywords'
		# 			return
		# 		when 'position'
		# 			params.type = 'Integer'
		# 	tr = "<tr>"
		# 	tr += model.columnType params.type, 'addColumn[]type', 'td'
		# 	tr += "<td>
		# 				<input type='text' name='addColumn[]name' value='#{params.name}'>
		# 			</td>
		# 			<td class='min'>
		# 				<input"
		# 	tr += ' disabled' if params.type is 'Decimal'
		# 	tr += " type='text' name='addColumn[]limit' data-type='limit' onkeypress='return event.charCode >= 48 && event.charCode <= 57'></td>
		# 			<td class='min'>
		# 				<input"
		# 	tr += ' disabled' unless params.type is 'Decimal'
		# 	tr += " value='#{params.precision}' type='text' name='addColumn[]precision' data-type='precision' onkeypress='return event.charCode >= 48 && event.charCode <= 57'>
		# 			</td>
		# 			<td class='min'>
		# 				<input"
		# 	tr += ' disabled' unless params.type is 'Decimal'
		# 	tr += " value='#{params.scale}' type='text' name='addColumn[]scale' data-type='scale'  onkeypress='return event.charCode >= 48 && event.charCode <= 57'>
		# 			</td>
		# 			<td>
		# 				<input type='text' name='addColumn[]default'>
		# 			</td>
		# 			<td>
		# 				<input type='checkbox' name='addColumn[]uniq'"
		# 	tr += " checked='checked'" if params.uniq
		# 	tr += ">
		# 			</td>
		# 			<td>
		# 				<input type='checkbox' name='addColumn[]null'"
		# 	tr += " checked='checked'" if params.null
		# 	tr += ">
		# 			</td>
		# 			<td class='btn red' onclick='act.remove.parent(this)'>Удалить</td>
		# 			<td class='btn deepblue'>Переместить</td>
		# 		</tr>"
		# 	$(el).parents('.add-column-wrap').find('table').append tr