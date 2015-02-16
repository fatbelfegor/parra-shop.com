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
				<form>
				<div class='btn green' onclick='view_index_save(this)'>Сохранить настройки</div>
				<br><br>
				<div class='panel'>
					<p>Структура</p>
					<div class='structure-wrap'>
						<div id='table-structure'>"
	template = models["#{name}_index"]
	if template
		for t in template.table
			ret += "<table onclick='tableStructure.table.pick(this)'>"
			for tr in t.tr
				ret += "<tr onclick='tableStructure.tr.pick(this)'>"
				for td in tr.td
					ret += "<td"
					ret += " colspan='#{td.colspan}'" if td.colspan
					ret += " rowspan='#{td.rowspan}'" if td.rowspan
					ret += " style='#{td.style}'" if td.style
					ret += " data-belongs_to='#{td.belongs_to}'" if td.belongs_to
					ret += " data-header='#{td.header}'" if td.header
					ret += " data-field='#{td.field}'" if td.field
					ret += " data-btn='#{td.btn}'" if td.btn
					ret += " data-btn-click='#{td.btnClick}'" if td.btnClick
					ret += " data-btn-icon='#{td.btnIcon}'" if td.btnIcon
					ret += " data-btn-td-class='#{td.btnTdClass}'" if td.btnTdClass
					ret += " data-btn-class='#{td.btnClass}'" if td.btnClass
					ret += " data-cb-type='#{td.cbType}'" if td.cbType
					ret += " data-cb-params='#{JSON.stringify td.cbParams}'" if td.cbParams
					ret += " onclick='tableStructure.td.pick(this)'><p>#{td.header or td.field or td.btn}</p><div class='hide cb'>"
					ret += td.cb if td.cb
					ret += "</div><span class='hide func'>"
					ret += td.func if td.func
					ret += "</span><span class='hide btnA'>"
					ret += td.btnA if td.btnA
					ret += "</span></td>"
				ret += "</tr>"
			ret += "</table>"
	else
		ret += "<div class='btn blue' onclick='tableStructure.generate(this, \"#{name}\")'>Создать таблицу</div>"
	ret += "</div><div class='panel red hide'>
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
								<label class='row mb10'><p>colspan</p><input type='text' name='colspan'></label>
								<label class='row mb10'><p>rowspan</p><input type='text' name='rowspan'></label>
								<label class='row mb10'><p>Стиль</p><input type='text' name='style'></label>
								<div class='buttons-group'>
									<div class='btn blue' onclick='tableStructure.td.before(this)'>Добавить td перед</div>
									<div class='btn blue' onclick='tableStructure.td.after(this)'>Добавить td после</div>
								</div><br>"
	ret += tab.gen
		"Функция": ->
			"<label class='row mb10'><p>Заглавие</p><input type='text' name='header'></label>
			<div class='ace-wrap'>
				<div id='ace-editor' class='editor'></div>
			</div>"
		"Поле": ->
			ret = "<div class='radio-nav'>
				<label onclick='preloadTab(this)' class='radio ib m15'><div class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='model_field' value='this'></div>Эта модель</label>
				<label onclick='preloadTab(this)' class='radio ib m15'><div><input onchange='radio(this)' type='radio' name='model_field' value='belongs_to'></div>belongs_to</label>
			</div>
			<div class='radio-tabs'>
				<div class='active current'>
					<label class='row mb10'><p>Заглавие</p><input type='text' name='header'></label>#{dropdown.gen head: 'Выбрать поле', list: table.columns.map((c) -> c.name), name: 'field'}
					<br><br>
					<div class='panel'>
						<p>Изменить значение</p>
						<div>
							<label class='mb10 checkbox'><div><input onchange='page.add_cb(this)' type='checkbox' name='add_cb'></div>Добавить обработчик</label><div class='hide'>"
			ret += tab.gen
				'Дата': ->
					"<label class='row'><p>Формат даты</p><input type='text' data-type='date-format' name='cb' value='dd.MM.yyyy'></label>
					<br><br>
					<table class='style'>
						<tr>
							<th>Формат</th>
							<th>Описание</th>
							<th>Результат</th>
						</tr>
						<tr>
							<td>s</td>
							<td>Секунды в диапазоне 0-59</td>
							<td>от 0 до 59</td>
						</tr>
						<tr>
							<td>ss</td>
							<td>Секунды, всегда 2 цифры</td>
							<td>от 00 до 59</td>
						</tr>
						<tr>
							<td>m</td>
							<td>Минуты в диапазоне 0-59</td>
							<td>от 0 до 59</td>
						</tr>
						<tr>
							<td>mm</td>
							<td>Минуты, всегда 2 цифры</td>
							<td>от 00 до 59</td>
						</tr>
						<tr>
							<td>h</td>
							<td>Часы утра/вечера в диапазоне 1-12</td>
							<td>от 1 до 12</td>
						</tr>
						<tr>
							<td>hh</td>
							<td>Часы утра/вечера, всегда 2 цифры</td>
							<td>от 01 до 12</td>
						</tr>
						<tr>
							<td>H</td>
							<td>Часы в сутках в диапазоне 0-23</td>
							<td>от 0 до 23</td>
						</tr>
						<tr>
							<td>HH</td>
							<td>Часы в сутках, всегда 2 цифры</td>
							<td>от 00 до 23</td>
						</tr>
						<tr>
							<td>d</td>
							<td>День месяца в диапазоне 1-31</td>
							<td>от 1 до 31</td>
						</tr>
						<tr>
							<td>dd</td>
							<td>День месяца, всегда 2 цифры</td>
							<td>от 01 до 31</td>
						</tr>
						<tr>
							<td>ddd</td>
							<td>Сокращенный день недели</td>
							<td>от \"Вс\" до \"Сб\"</td>
						</tr>
						<tr>
							<td>dddd</td>
							<td>День недели</td>
							<td>от \"воскресенье\" до \"суббота\"</td>
						</tr>
						<tr>
							<td>M</td>
							<td>Месяц в диапазоне 1-12</td>
							<td>от 1 до 12</td>
						</tr>
						<tr>
							<td>MM</td>
							<td>Месяц, всегда 2 цифры</td>
							<td>от 01 до 12</td>
						</tr>
						<tr>
							<td>MMM</td>
							<td>Сокращенное название месяца</td>
							<td>от \"янв\" до \"дек\"</td>
						</tr>
						<tr>
							<td>MMMM</td>
							<td>Название месяца</td>
							<td>от \"января\" до \"декабря\"</td>
						</tr>
						<tr>
							<td>yy</td>
							<td>Последние 2 цифры года</td>
							<td>от 00 до 99</td>
						</tr>
						<tr>
							<td>yyyy</td>
							<td>Полный год</td>
							<td>2015</td>
						</tr>
					</table>"
			ret += "</div></div></div></div>
				<div class='belongs_to'><label class='row mb10'><p>Заглавие</p><input type='text' name='header'></label>"
			preloadTabs = {}
			for m in template.belongs_to
				preloadTabs[m.model] = ->
					dropdown.gen head: 'Выбрать поле', list: tables[m.model].columns.map((c) -> c.name), name: 'field'
			ret + tab.gen(preloadTabs) + "</div>
			</div>"
		"Кнопка": ->
			ret = "<label class='row mb10'><p>Заглавие</p><input type='text' name='header'></label>
				<div class='btn-types'>
					<label onclick='page.selectButton(this)' class='radio ib m15'><div class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='selectButton' value='custom'></div><span>Настроить кнопку</span></label>
					<label onclick='page.selectButton(this)' class='radio ib m15'><div><input onchange='radio(this)' type='radio' name='selectButton' value='edit'></div><span>Редактировать</span></label>
					<label onclick='page.selectButton(this)' class='radio ib m15'><div><input onchange='radio(this)' type='radio' name='selectButton' value='edit'></div><span>Удалить</span></label>
				</div>
				<div>
					<label class='row mb10'><p>Тип кнопки</p><input type='text' name='btn' value='custom'></label>
					<label class='row mb10'><p>Класс ячейки</p><input type='text' name='td-class'></label>
					<label class='row mb10'><p>Класс кнопки</p><input type='text' name='class'></label>
					<label class='row mb10'><p>Иконка</p><input type='text' name='icon'></label>
					<label class='row mb10'><p>Событие onclick</p><input type='text' name='click'></label>
					<div class='panel'>
						<p>Ссылка</p>
						<div>
							<div class='ace-wrap'>
								<div id='ace-btn-a' class='editor'></div>
							</div>
						</div>
					</div>
				</div>"
	ret += "<br><div class='buttons-group'>
									<div class='btn green' onclick='tableStructure.td.save(this)'>Сохранить</div>
									<div class='btn red' onclick='tableStructure.td.remove(this)'>Удалить</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<br>
				<div class='panel'>
					<p>Загрузка дополнительных моделей</p>
					<div>"
	ret += tab.gen
		'belongs_to': ->
			ret = "<div class='association-wrap' data-type='belongs_to'><br><div data-content='model-names' class='buttons-list'>"
			belongs_to = []
			belongs_to.push n.model for n in template.belongs_to if template.belongs_to
			for n in table.belongs_to
				for n, v of n
					if n not in belongs_to
						ret += "<div class='btn blue' onclick='model.association(this, true)'>#{tables[n].singularize}</div>"
					break
			ret += "</div><br><div class='center-row insert belongs_to'>"
			for n in belongs_to
				ret += "<label class='row'>
					<input type='text' name='belongs_to[]name' value='#{n}'>
					<i class='icon-cancel-circle' onclick='model.association_rm(this)'></i>
				</label>"
			ret + "</div></div>"
		'has_many': ->
			ret = "<div class='association-wrap' data-type='has_many'><br><div data-content='model-names' class='buttons-list'>"
			has_many = []
			if template.has_many
				for n in template.has_many
					has_many.push n.model
			for n in table.has_many
				for n, v of n
					if n not in has_many
						ret += "<div class='btn blue' onclick='model.association(this, true)'>#{tables[n].singularize}</div>"
					break
			ret += "</div><br><div class='center-row insert has_many'>"
			for n in has_many
				ret += "<label class='row'>
					<input type='text' name='has_many[]name' value='#{n}'>
					<i class='icon-cancel-circle' onclick='model.association_rm(this)'></i>
				</label>"
			ret + "</div></div>"
	ret += "<br><div class='btn green' onclick='page.save_preload_associations(this)'>Сохранить</div></div>
				</div>
				<br>
				<div class='btn green' onclick='view_index_save(this)'>Сохранить настройки</div>
				</div>
			</div>
			<br>
		</div>
		<br>
	</div>
	<script src='/ace/ace.js'>"
	ret
app.after = ->
	window.aceEditor = ace.edit "ace-editor"
	aceEditor.getSession().setMode "ace/mode/javascript"
	aceEditor.setValue "(function(rec){\n\tret = \"\"\n\treturn ret\n})"
	window.aceBtnA = ace.edit "ace-btn-a"
	aceBtnA.getSession().setMode "ace/mode/javascript"
	aceBtnA.setValue "(function(rec, name){\n\treturn \"\"\n})"
window.page =
	add_cb: (el) ->
		$(el).parents('label').next().toggleClass 'hide'
		checkbox el
	save_preload_associations: (el) ->
		el = $ el
		preload = {}
		for t in ['belongs_to', 'has_many']
			preload[t] = []
			el.parents('.tabs').find(".#{t} input").each ->
				preload[t].push name: $(@).val()
	selectButton: (el) ->
		el = $ el
		name = el.find('span').html()
		parent = el.parent()
		wrap = parent.next()
		if name is 'Настроить кнопку'
			wrap.removeClass 'hide'
		else
			wrap.addClass 'hide'
			parent.prev().find('input').val name
			switch name
				when 'Настроить кнопку'
					wrap.find("[name='btn']").val ''
					wrap.find("[name='td-class']").val ''
					wrap.find("[name='class']").val ''
					wrap.find("[name='click']").val ''
					wrap.find("[name='icon']").val ''
					aceBtnA.setValue "(function(rec, name){\n\treturn \"\"\n})"
				when 'Редактировать'
					wrap.find("[name='btn']").val 'edit'
					wrap.find("[name='td-class']").val 'orange'
					wrap.find("[name='class']").val 'edit'
					wrap.find("[name='click']").val ''
					wrap.find("[name='icon']").val ''
					aceBtnA.setValue "(function(rec, name){\n\treturn \"/admin/model/\" + name + \"/edit/\" + rec.id\n})"
				when 'Удалить'
					wrap.find("[name='btn']").val 'remove'
					wrap.find("[name='td-class']").val 'red'
					wrap.find("[name='class']").val 'remove'
					wrap.find("[name='click']").val ''
					wrap.find("[name='icon']").val ''
					aceBtnA.setValue ""
window.preloadTab = (el) ->
	el = $ el
	tabs = el.parent().next()
	tabs.find('> .active').removeClass 'active'
	tabs.find('> div').eq(el.index()).addClass 'active'
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
				cb = el.find('.cb').text()
				data.cb = cb if cb isnt ''
				func = el.find('.func').text()
				data.func = func if func isnt ''
				btnA = el.find('.btnA').text()
				data.btnA = btnA if btnA isnt ''
				colspan = el.attr 'colspan'
				data.colspan = colspan if colspan and colspan > 0
				rowspan = el.attr 'rowspan'
				data.rowspan = rowspan if rowspan and rowspan > 0
				style = el.attr 'style'
				data.style = style if style and style isnt ''
				tr_json.td.push data
			table_json.tr.push tr_json
		models["#{name}_index"].table.push table_json
	for t in ['belongs_to', 'has_many']
		models["#{name}_index"][t] = []
		wrap.parents('form').find("[name='#{t}[]name']").each ->
			models["#{name}_index"][t].push model: $(@).val()
	data =
		path: "app/assets/javascripts/admin/models/#{name}/index.coffee"
		file: "models.#{name}_index = #{JSON.stringify models["#{name}_index"]}"
	send "write", data, "Настройки сохранены"
window.tableStructure =
	generate: (el, name) ->
		table = tables[name]
		ret = "<table onclick='tableStructure.table.pick(this)'>
			<tr onclick='tableStructure.tr.pick(this)'>"
		choosed = table.columns.filter (c) -> c.name in ['name', 'scode', 'email', 'phone', 'price']
		for c in table.columns
			break if choosed.length is 5
			choosed.push c if c.type is 'string'
		for c in choosed
			ret += "<td data-header='#{c.name}' data-field='#{c.name}' onclick='tableStructure.td.pick(this)'><p>#{c.name}</p></td>"
		ret += "<td data-btn='edit' onclick='tableStructure.td.pick(this)'><p>edit</p></td>"
		ret += "<td data-btn='remove' onclick='tableStructure.td.pick(this)'><p>remove</p></td>"
		ret += "</tr>
		</table>"
		$(el).parent().html ret
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
			tableStructure.prepend el, "<td onclick='tableStructure.td.pick(this)'><p>td</p><div class='hide cb'></div></td>"
		append: (el) ->
			tableStructure.append el, "<td onclick='tableStructure.td.pick(this)'><p>td</p><div class='hide cb'></div></td>"
		remove: (el) ->
			tableStructure.remove el
	td:
		pick: (el) ->
			event.stopPropagation()
			if blue = tableStructure.pick el, 'blue'
				el = $ el
				data = el.data()
				colspan = el.attr 'colspan'
				rowspan = el.attr 'rowspan'
				style = el.attr 'style'
				blue.find("[name='colspan']").val colspan if colspan isnt ''
				blue.find("[name='rowspan']").val rowspan if rowspan isnt ''
				blue.find("[name='style']").val style if style isnt ''
				blue.find("[name='header']").val data.header if data.header
				if data.field
					openTab blue.find(".nav-tabs > *")[1]
					input = blue.find("[name='field']").val data.field
					list = input.prev()
					list.find(".active").removeClass 'active'
					list.find("> *").each ->
						el = $ @
						if el.html() is data.field
							el.addClass 'active'
					list.prev().html data.field
				if data.btn
					openTab blue.find(".nav-tabs > *")[2]
					if data.btn is 'edit'
						index = 1
					else if data.btn is 'remove'
						index = 2
					else index = 0
					label = blue.find('.btn-types label').eq(index)
					radio label.find('input').prop('checked', true)[0]
					page.selectButton label[0]
					blue.find("[name='btn']").val data.btn
					blue.find("[name='td-class']").val data.btnTdClass
					blue.find("[name='class']").val data.btnClass
					blue.find("[name='click']").val data.btnClick
					blue.find("[name='icon']").val data.btnIcon
					aceBtnA.setValue el.find('.btnA').html()
				if data.cbType
					page.add_cb blue.find("[name='add_cb']").prop('checked', true)[0]
					typeHtml = switch data.cbType
						when 'date'
							'Дата'
					blue.find('.nav-tabs div').each ->
						openTab @ if $(@).html() is typeHtml
					switch data.cbType
						when 'date'
							blue.find(".tabs .active [name='cb']").val data.cbParams.format
				func = el.find('.func').text()
				aceEditor.setValue func if func isnt ''
		before: (el) ->
			tableStructure.before el, "<td onclick='tableStructure.td.pick(this)'><p>td</p><div class='hide cb'></div></td>"
		after: (el) ->
			tableStructure.after el, "<td onclick='tableStructure.td.pick(this)'><p>td</p><div class='hide cb'></div></td>"
		save: (el) ->
			el = $ el
			panel = el.parents '.panel'
			blue = panel.find '.panel.blue'
			data = {}
			index = blue.find "> div > .nav-tabs > .active"
			active_tab = blue.find "> div > .tabs > .active"
			td = panel.find('#table-structure .active')
			td.attr colspan: (parseInt(blue.find("[name='colspan']").val()) or 0), rowspan: (parseInt(blue.find("[name='rowspan']").val()) or 0), style: blue.find("[name='style']").val()
			td.removeData()
			cb = td.find('.cb').html ''
			func = td.find('.func').html ''
			switch index.html()
				when 'Функция'
					data.header = active_tab.find("[name='header']").val()
					func.html aceEditor.getValue()
				when 'Поле'
					active_model = active_tab.find('.radio-tabs > .active')
					data.belongs_to = active_model.find('.nav-tabs > .active').html() if active_model.hasClass 'belongs_to'
					header = active_model.find("[name='header']").val()
					data.field = active_model.find("[name='field']").val()
					if header is ''
						data.header = data.field
					else
						data.header = header
					if active_model.find("[name='add_cb']").prop 'checked'
						switch active_model.find(".nav-tabs .active").html()
							when 'Дата'
								data.cbType = 'date'
								data.cbParams = format: active_model.find("[name='cb']").val()
								cb.html "(function(d, params){return new Date(d).toString(params.format)})"
				when 'Кнопка'
					header = active_tab.find("[name='header']").val()
					data.header = header unless header is ''
					data.btn = active_tab.find("[name='btn']").val()
					data.btnClick = active_tab.find("[name='click']").val()
					data.btnTdClass = active_tab.find("[name='td-class']").val()
					data.btnClass = active_tab.find("[name='class']").val()
					data.btnIcon = active_tab.find("[name='icon']").val()
					btnA = aceBtnA.getValue()
					td.find('.btnA').html btnA unless btnA is ''
			td.data(data).find('p').html data.header
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
			panel.find('> .structure-wrap > .panel').addClass 'hide'
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