@model = {}
app.page = ->
	ret = "<h1>Создать новую модель</h1>
	<div class='content'>
		<form action='model/create'>
			<div class='btn green m15' onclick='functions.create(this)'>Создать</div>
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
		ret += "<div class='btn blue' onclick='functions.association(this, true)'>#{n}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='functions.association(this)'>Добавить</div>
					<br>
				</div>
				<div class='association-wrap' data-type='has_many'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of models
		ret += "<div class='btn blue' onclick='functions.association(this, true)'>#{table.pluralize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='functions.association(this)'>Добавить</div>
					<br>
				</div>
				<div class='association-wrap' data-type='has_one'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n of models
		ret += "<div class='btn blue' onclick='functions.association(this, true)'>#{n}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='functions.association(this)'>Добавить</div>
					<br>
				</div>
				<!--<div class='association-wrap' data-type='has_and_belongs_to_many'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of models
		ret += "<div class='btn blue' onclick='functions.association(this, true)'>#{table.singularize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green' onclick='functions.association(this)'>Добавить</div>
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
			$('.association-wrap').each ->
				el = $ @
				type = el.data 'type'
				el.find('.insert > div').each ->
					a = $ @
					input = a.find 'input'
					if input[0]
						data.push name: "#{type}[]name", value: input.val()
					else
						data.push name: "#{type}[]name", value: a.find('p').html()
			$.post "/admin/#{form.attr('action')}", data, ->
					notify "Модель успешно создана"
				, 'json'
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
					return
				when 'position'
					f.type = 'Integer'
		ret = "<tr>
			<td>
				<div class='dropdown' onclick='dropdown.toggle(this)'>
					<p>#{f.type}</p>
					<div>"
		for n in ['Binary', 'Boolean', 'Date', 'Datetime', 'Decimal', 'Float', 'Integer', 'Primary_key', 'String', 'Text', 'Time', 'Timestamp']
			ret += "<p#{if n is f.type then " class='active'" else ''} onclick='functions.dropdownPick(this)'>#{n}</p>"
		ret += "</div>
				<input type='hidden' name='addColumn[]type' value='#{f.type}'>
				</div>
			</td>
			<td><input type='text' name='addColumn[]name' value='#{f.name}'></td>
			<td><input type='text' name='addColumn[]limit' value='#{f.limit}'#{if f.type is 'Decimal' then ' disabled' else ''}></td>
			<td class='min'><input type='text' name='addColumn[]precision'#{if f.type is 'Decimal' then '' else ' disabled'} value='#{f.precision}'></td>
			<td class='min'><input type='text' name='addColumn[]scale'#{if f.type is 'Decimal' then '' else ' disabled'} value='#{f.scale}'></td>
			<td><input type='text' name='addColumn[]default' value='#{f.default}'></td>
			<td><label class='checkbox'><div#{if f.index then " class='checked'" else ''}><input#{if f.index then " checked='checked'" else ''} type='checkbox' name='addColumn[]index' onchange='checkbox(this)'></div></label></td>
			<td><label class='checkbox'><div#{if f.uniq then " class='checked'" else ''}><input#{if f.uniq then " checked='checked'" else ''} type='checkbox' name='addColumn[]uniq' onchange='functions.checkboxUniq(this)'></div></label></td>
			<td><label class='checkbox'><div#{if f.null then " class='checked'" else ''}><input#{if f.null then " checked='checked'" else ''} type='checkbox' name='addColumn[]null' onchange='checkbox(this)'></div></label></td>
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
	dropdownPick: (el) ->
		el = $ el
		dd = el.parents '.dropdown'
		val = el.html()
		dd.find('> p').html val
		dd.find('input').val val
	association: (el, val) ->
		el = $ el
		wrap = el.parents '.association-wrap'
		if val
			wrap.find('.insert').append "<div class='row'><p style='width: 100%'>#{el.html()}</p><i style='width: 1%; line-height: 25px' onclick='$(this).parent().remove()' class='btn red icon-remove'></i></div>"
		else
			wrap.find('.insert').append "<div class='row'><input type='text'><i style='line-height: 25px' onclick='$(this).parent().remove()' class='btn red icon-remove'></i></div>"