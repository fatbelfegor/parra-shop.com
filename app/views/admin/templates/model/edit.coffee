app.page = ->
	name = app.data.route.model
	table = tables[name]
	ret = "<h1>Редактировать модель <b>#{name}</b></h1>
	<div class='content'>
		<br>
		<div class='nav-tabs'>
			<p onclick='openTab(this)'>Добавить поля</p>
			<p onclick='openTab(this)'>Удалить поля</p>
			<p onclick='openTab(this)' class='active'>Страница записей</p>
		</div>
		<div class='tabs'>
			<div class='add-column-wrap'>
				<form>
					<table class='style'>
						<tr>
							<th>Type</th>
							<th>Name</th>
							<th>Limit</th>
							<th>Precision</th>
							<th>Scale</th>
							<th>Default</th>
							<th>Uniq</th>
							<th>Null</th>
							<th></th>
							<th></th>
						</tr>
					</table>
					<br>
					<div>
						<div class='btn green' onclick='model.column.add(this)'>Добавить поле</div>
						<div class='btn white' onclick='model.column.add(this, \"name\")'>Название</div>
						<div class='btn white' onclick='model.column.add(this, \"scode\")'>Код</div>
						<div class='btn white' onclick='model.column.add(this, \"article\")'>Артикул</div>
						<div class='btn white' onclick='model.column.add(this, \"short_desc\")'>Краткое описание</div>
						<div class='btn white' onclick='model.column.add(this, \"description\")'>Описание</div>
						<div class='btn white' onclick='model.column.add(this, \"price\")'>Цена</div>
						<div class='btn white' onclick='model.column.add(this, \"image\")'>Изображение</div>
						<div class='btn white' onclick='model.column.add(this, \"seo\")'>Seo</div>
						<div class='btn white' onclick='model.column.add(this, \"position\")'>Позиция</div>
					</div>
					<br>
					<div class='labels'>"
	for n of tables
		if n is 'image'
			if 'images' in table.has_many
				images = true
			ret += "<label class='checkbox'><div#{if images then " class='checked'" else ''}><input#{if images then " checked='checked'" else ''} onchange='checkbox(this)' type='checkbox' name='imageable'></div>Множество картинок</label>"
			break
	for column, i in table.columns
		timestamps = true if column.name is 'created_at' and table.columns[i + 1].name is 'updated_at'
	ret += "<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='acts_as_tree'></div>Принадлежит сама себе</label>
						<label class='checkbox'><div#{if timestamps then " class='checked'" else ''}><input#{if timestamps then " checked='checked'" else ''} name='timestamps' onchange='checkbox(this)' type='checkbox'></div>Timestamps</label>
					</div>
					<br>
					<div class='btn green' onclick='model.update(this)'>Сохранить</div>
				</form>
			</div>
			<div>
				<form>
					<table class='style'>
						<tr>
							<th>Type</th>
							<th>Name</th>
							<th>Limit</th>
							<th>Precision</th>
							<th>Scale</th>
							<th>Default</th>
							<th>Uniq</th>
							<th>Null</th>
							<th></th>
						</tr>"
	modelTable = app.data.model[name]
	for c in modelTable.columns
		uniq = false
		for i in modelTable.indexes
			uniq = true if c.name in i
		ret += "<tr>
			<td>#{c.type}</td>
			<td class='name' data-name='#{c.name}'>#{c.name}</td>
			<td>#{if c.limit then c.limit else ''}</td>
			<td>#{if c.precision then c.precision else ''}</td>
			<td>#{if c.scale then c.scale else ''}</td>
			<td>#{if c.default then c.default else ''}</td>
			<td><input type='checkbox' disabled #{if uniq then "checked='checked'" else ''}></td>
			<td><input type='checkbox' disabled #{if c.null then "checked='checked'" else ''}></td>
			<td class='btn red' onclick='model.column.remove(this)'>Удалить</td>
		</tr>"
	ret += "</table>
					<br>
					<h2>На удаление:</h2>
					<div class='to_remove'></div>
					<br>
					<div class='btn green' onclick='model.update(this)'>Сохранить</div>
				</form>
			</div>
			<div class='active'>
				<div class='btn green' onclick='view_index_save(this)'>Сохранить настройки</div>
				<div class='panel'>
					<p>Структура</p>
					<div class='structure-wrap'>
						<div id='table-structure'>"
	template = models["#{name}_index"]
	for t in template.table
		ret += "<table onclick='tableStructure.table.pick(this)'>"
		for tr in t.tr
			ret += "<tr onclick='tableStructure.tr.pick(this)'>"
			for td in tr.td
				ret += "<td"
				ret += " data-header='#{td.header}'" if td.header
				ret += " data-field='#{td.field}'" if td.field
				ret += " data-btn='#{td.btn}'" if td.btn
				ret += " onclick='tableStructure.td.pick(this)'><p>#{td.header or td.field or td.btn}</p></td>"
			ret += "</tr>"
		ret += "</table>"
	ret += "</div>
						<div class='panel red hide'>
							<p>table</p>
							<div class='buttons-group'>
								<div class='btn red' onclick='tableStructure.table.before(this)'>Добавить table перед</div>
								<div class='btn red' onclick='tableStructure.table.after(this)'>Добавить table после</div>
								<br>
								<div class='btn green' onclick='tableStructure.table.prepend(this)'>Добавить tr в начало</div>
								<div class='btn green' onclick='tableStructure.table.append(this)'>Добавить tr в конец</div>
								<br>
								<div class='btn red' onclick='tableStructure.table.remove(this)'>Удалить</div>
							</div>
						</div>
						<div class='panel green hide'>
							<p>tr</p>
							<div class='buttons-group'>
								<div class='btn green' onclick='tableStructure.tr.before(this)'>Добавить tr перед</div>
								<div class='btn green' onclick='tableStructure.tr.after(this)'>Добавить tr после</div>
								<br>
								<div class='btn blue' onclick='tableStructure.tr.prepend(this)'>Добавить td в начало</div>
								<div class='btn blue' onclick='tableStructure.tr.append(this)'>Добавить td в конец</div>
								<br>
								<div class='btn red' onclick='tableStructure.tr.remove(this)'>Удалить</div>
							</div>
						</div>
						<div class='panel blue hide'>
							<p>td</p>
							<div>
								<label class='row'><p>colspan</p><input type='text' name='colspan'></label>
								<label class='row'><p>rowspan</p><input type='text' name='rowspan'></label>
								<div class='buttons-group'>
									<div class='btn blue' onclick='tableStructure.td.before(this)'>Добавить td перед</div>
									<div class='btn blue' onclick='tableStructure.td.after(this)'>Добавить td после</div>
								</div><br>"
	ret += tab.gen
		"Поле": ->
			"<label class='row'><p>Заглавие</p><input type='text' name='header'></label>" + dropdown.gen head: 'Выбрать поле', list: table.columns.map((c) -> c.name), name: 'field'
		"Кнопка": ->
			dropdown.gen head: 'Выбрать кнопку', list: [{name: 'Редактировать', val: 'edit'}, {name: 'Удалить', val: 'remove'}], name: 'btn'
	ret += "<br><div class='buttons-group'>
									<div class='btn green' onclick='tableStructure.td.save(this)'>Сохранить</div>
									<div class='btn red' onclick='tableStructure.td.remove(this)'>Удалить</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<br>
				<div class='btn green' onclick='view_index_save(this)'>Сохранить настройки</div>
			</div>
		</div>
		<br>
	</div>"
	ret
window.view_index_save = (el) ->
	name = app.data.route.model
	models["#{name}_index"] = {}
	wrap = $(el).parent().find("#table-structure")
	tabls = wrap.find "> table"
	models["#{name}_index"].table = [] if tabls.length > 0
	tabls.each ->
		el = $ @
		table_json = {}
		trs = el.find "> tbody > tr"
		table_json.tr = [] if trs.length > 0
		trs.each ->
			el = $ @
			tr_json = {}
			tds = el.find "> td"
			tr_json.td = [] if tds.length > 0
			tds.each ->
				el = $ @
				data = el.data()
				colspan = el.attr 'colspan'
				data.colspan = colspan if colspan
				rowspan = el.attr 'rowspan'
				data.rowspan = rowspan if rowspan
				tr_json.td.push data
			table_json.tr.push tr_json
		models["#{name}_index"].table.push table_json
	data =
		path: "app/assets/javascripts/admin/models/#{name}/index.coffee"
		file: "models.product_index = #{JSON.stringify models["#{name}_index"]}"
	act.sendData "write", data, "Настройки сохранены"
window.tableStructure =
	table:
		pick: (el) ->
			tableStructure.pick el, 'red'
		before: (el) ->
			tableStructure.before el, "<table onclick='tableStructure.table.pick(this)'></table>"
		after: (el) ->
			tableStructure.after el, "<table onclick='tableStructure.table.pick(this)'></table>"
		prepend: (el) ->
			tableStructure.prepend el, "<tr onclick='tableStructure.tr.pick(this)'></tr>"
		append: (el) ->
			tableStructure.append el, "<tr onclick='tableStructure.tr.pick(this)'></tr>"
		remove: (el) ->
			tableStructure.remove el
	tr:
		pick: (el) ->
			event.stopPropagation()
			tableStructure.pick el, 'green'
		before: (el) ->
			tableStructure.before el, "<tr onclick='tableStructure.tr.pick(this)'></tr>"
		after: (el) ->
			tableStructure.after el, "<tr onclick='tableStructure.tr.pick(this)'></tr>"
		prepend: (el) ->
			tableStructure.prepend el, "<td onclick='tableStructure.td.pick(this)'><p>td</p></td>"
		append: (el) ->
			tableStructure.append el, "<td onclick='tableStructure.td.pick(this)'><p>td</p></td>"
		remove: (el) ->
			tableStructure.remove el
	td:
		pick: (el) ->
			event.stopPropagation()
			if blue = tableStructure.pick el, 'blue'
				data = $(el).data()
				blue.find("[name='header']").val data.header if data.header
				if data.field
					openTab blue.find(".nav-tabs > *")[0]
					input = blue.find("[name='field']").val data.field
					list = input.prev()
					list.find(".active").removeClass 'active'
					list.find("> *").each ->
						el = $ @
						if el.html() is data.field
							el.addClass 'active'
					list.prev().html data.field
				if data.btn
					openTab blue.find(".nav-tabs > *")[1]
					input = blue.find("[name='btn']").val data.btn
					list = input.prev()
					list.find(".active").removeClass 'active'
					btn_name = switch data.btn
						when 'edit'
							'Редактировать'
						when 'remove'
							'Удалить'
					list.find("> *").each ->
						el = $ @
						if el.html() is btn_name
							el.addClass 'active'
					list.prev().html btn_name
		before: (el) ->
			tableStructure.before el, "<td onclick='tableStructure.td.pick(this)'><p>td</p></td>"
		after: (el) ->
			tableStructure.after el, "<td onclick='tableStructure.td.pick(this)'><p>td</p></td>"
		save: (el) ->
			el = $ el
			panel = el.parents '.panel'
			blue = panel.find '.panel.blue'
			data = {}
			index = blue.find(".nav-tabs .active").index()
			active_tab = blue.find(".tabs > div").eq index
			switch index
				when 0
					header = active_tab.find("[name='header']").val()
					data.header = header unless header is ''
					data.field = active_tab.find("[name='field']").val()
				when 1
					data.btn = active_tab.find("[name='btn']").val()
			td = panel.find('#table-structure .active')
			td.attr colspan: (parseInt(blue.find("[name='colspan']").val()) or 0), rowspan: (parseInt(blue.find("[name='rowspan']").val()) or 0)
			td.removeData().data data
		remove: (el) ->
			tableStructure.remove el
	pick: (el, color) ->
		el = $ el
		if el.hasClass 'active'
			el.removeClass('active').parents('.panel').find(".panel.#{color}").addClass 'hide'
			false
		else
			panel = el.parents '.panel'
			panel.find('#table-structure .active').removeClass 'active'
			panel.find('.panel').addClass 'hide'
			el.addClass 'active'
			panel.find(".panel.#{color}").removeClass 'hide'
	before: (el, html) ->
		$(el).parents('.structure-wrap').find('#table-structure .active').before html
	after: (el, html) ->
		$(el).parents('.structure-wrap').find('#table-structure .active').after html
	prepend: (el, html) ->
		$(el).parents('.structure-wrap').find('#table-structure .active').prepend html
	append: (el, html) ->
		$(el).parents('.structure-wrap').find('#table-structure .active').append html
	remove: (el) ->
		wrap = $(el).parents('.structure-wrap')
		wrap.find('.panel').addClass 'hide'
		wrap.find('#table-structure .active').remove()
model.update = (el) ->
	form = $(el).parent()
	model = $('h1 b').html()
	table = tables[model]
	serialize = form.serializeArray()
	data = {}
	for s in serialize
		switch s.name
			when 'imageable'
				data.imageable = true
			when 'timestamps'
				data.timestamps = true
			when 'remove[]'
				data.remove = [] if !data.remove
				data.remove.push s.value
	for c, i in table.columns
		if c.name is 'created_at' and table.columns[i + 1].name is 'updated_at'
			if data.timestamps
				delete data.timestamps
			else
				data.remove_timestamps = true
	if 'images' in table.has_many
		if data.imageable
			delete data.imageable
		else
			data.remove_imageable = true
	act.sendData "model/#{model}/update", data, 'Модель обновлена'
model.column.remove = (el) ->
	tr = $(el).parent()
	name = tr.find('.name').data 'name'
	tr.parents('.active').find('.to_remove').append "<span class='btn red'><span>#{name}</span> <i class='icon-close' onclick='model.column.return(this)'></i><input type='hidden' name='remove[]' value='#{name}'></span>"
	tr.hide()
model.column.return = (el) ->
	el = $ el
	name = el.prev().html()
	el.parents('.active').find("[data-name=#{name}]").parent().show()
	el.parent().remove()