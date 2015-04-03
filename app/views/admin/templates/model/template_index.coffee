app.page = ->
	template = app.templates.index[param.model]
	ret = "<h1>Все записи <b>#{param.model}</b></h1>
	<div class='content'>
		<br>
		<div class='btn green mb10' onclick='functions.save()'>Сохранить</div><br>
		<div class='btn purple' onclick='functions.generateAsk()'>Создать автоматически</div>
		<div id='table-structure'>"
	if template
		for t in template.table
			ret += "<table onclick='functions.pick(\"table\", this)'"
			if t.attrs
				ret += " data-attrs='#{JSON.stringify t.attrs}'"
				for k, v of t.attrs
					ret += " #{k}='#{v}'" unless k in ['class', 'onclick']
			ret += ">"
			for tr in t.tr
				ret += "<tr onclick='functions.pick(\"tr\", this)'"
				if tr.attrs
					ret += " data-attrs='#{JSON.stringify tr.attrs}'"
					for k, v of tr.attrs
						ret += " #{k}='#{v}'" unless k in ['class', 'onclick']
				ret += ">"
				ret += "<td class='set hidden'>#{tr.setPlain}</td>" if tr.setPlain
				for td in tr.td
					ret += "<td onclick='functions.pick(\"td\", this)'"
					ret += " data-header='#{td.header}'" if td.header
					ret += " data-belongs_to='#{td.belongs_to}'" if td.belongs_to
					ret += " data-format='#{JSON.stringify td.format}'" if td.format
					ret += " data-html='true'" if td.html
					ret += " data-show='#{td.show}'" if td.show
					if td.attrs
						ret += " data-attrs='#{JSON.stringify td.attrs}'"
						for k, v of td.attrs
							ret += " #{k}='#{v}'" unless k in ['class', 'onclick']
					ret += "><div>"
					if td.html
						ret += td.html
					else if td.header
						ret += td.header
					else if td.show
						ret += td.show
					else if td.set
						ret += "* функция *"
					else
						ret += "&nbsp;"
					ret += "</div>"
					ret += "<div class='set hide'>#{td.setPlain}</div>" if td.setPlain
					ret += "</td>"
				ret += "</tr>"
			ret += "</table>"
	else
		ret += "<table onclick='functions.pick(\"table\", this)'>
			<tr onclick='functions.pick(\"tr\", this)'>
				<td onclick='functions.pick(\"td\", this)' data-html='true'>
					<div class='html hide'>Ячейка</div>
					<p>Ячейка</p>
				</td>
			</tr>
		</table>"
	ret += "</div>
		<div id='panels'>
			<div class='panel red hide'>
				<p>Table</p>
				<div>
					<div class='btn green mb10'>Сохранить</div>
					<br>
					<div class='btn gray' onclick='functions.add(\"table\", \"before\")'>Добавить <b>Table</b> перед</div>
					<div class='btn gray' onclick='functions.add(\"table\", \"after\")'>Добавить <b>Table</b> после</div>
					<div class='btn gray' onclick='functions.add(\"tr\", \"prepend\")'>Добавить <b>Tr</b> в начало</div>
					<div class='btn gray' onclick='functions.add(\"tr\", \"append\")'>Добавить <b>Tr</b> в конец</div>
					<div class='btn red' onclick='functions.remove(this)'>Удалить</div>
					<br><br>
					<div class='panel' style='margin: 5px 50px'>
						<p>Атрибуты</p>
						<div>
							<table class='style attr mb10'>
								<tr>
									<th>Название</th>
									<th>Значение</th>
									<th></th>
								</tr>
								<tr>
									<td>
										<input type='text' name='name'>
									</td>
									<td>
										<input type='text' name='val'>
									</td>
									<td>
										<div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div>
									</td>
								</tr>
							</table>
							<div class='btn blue' onclick='functions.addAttr(this)'>Добавить</div>
						</div>
					</div>
				</div>
			</div>
			<div class='panel green hide'>
				<p>Tr</p>
				<div>
					<div class='btn green mb10'>Сохранить</div>
					<br>
					<div class='btn gray' onclick='functions.add(\"tr\", \"before\")'>Добавить <b>Tr</b> перед</div>
					<div class='btn gray' onclick='functions.add(\"tr\", \"after\")'>Добавить <b>Tr</b> после</div>
					<div class='btn gray' onclick='functions.add(\"td\", \"prepend\")'>Добавить <b>Td</b> в начало</div>
					<div class='btn gray' onclick='functions.add(\"td\", \"append\")'>Добавить <b>Td</b> в конец</div>
					<div class='btn red' onclick='functions.remove(this)'>Удалить</div>
					<br><br>
					<div class='panel' style='margin: 5px 50px'>
						<p>Атрибуты</p>
						<div>
							<table class='style attr mb10'>
								<tr>
									<th>Название</th>
									<th>Значение</th>
									<th></th>
								</tr>
								<tr>
									<td>
										<input type='text' name='name'>
									</td>
									<td>
										<input type='text' name='val'>
									</td>
									<td>
										<div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div>
									</td>
								</tr>
							</table>
							<div class='btn blue' onclick='functions.addAttr(this)'>Добавить</div>
						</div>
					</div>
					<br>
					<div class='panel' style='margin: 5px 50px 20px'>
						<p>Функция set: (data) -> &nbsp;&nbsp;<span style='color: #888'># data.rec - текущая запись, data.recs - все записи в коллекции tr</span></p>
						<div>
							<div class='ace-wrap'>
								<div id='ace-tr-set' class='editor'></div>
							</div>
							<br>
							<div class='btn green' onclick='functions.addAttr(this)'>Сохранить функцию</div>
						</div>
					</div>
					<label class='checkbox'>
						<div><input type='checkbox' onchange='functions.trCollection(this)' name='collection'></div> Строка для каждой записи в коллекции
					</label>
					<div class='panel hide' style='margin: 5px 50px 20px'>
						<p>Коллекция</p>
						<div>
							<div class='ib'>
								<label style='max-width: 300px' class='row mb10'><p>Тип коллекции</p><input type='text' name='collection-type'></label>
								<label style='max-width: 300px' class='row'><p>Модель</p><input type='text' name='collection-model'></label>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class='panel blue hide'>
				<p>Td</p>
				<div>
					<div class='btn green mb10'>Сохранить</div>
					<br>
					<div class='btn gray' onclick='functions.add(\"td\", \"before\")'>Добавить <b>Td</b> перед</div>
					<div class='btn gray' onclick='functions.add(\"td\", \"after\")'>Добавить <b>Td</b> после</div>
					<div class='btn red' onclick='functions.remove(this)'>Удалить</div>
					<br><br>
					<form class='mb10'>
						<label class='radio ib' style='margin: 0 15px'><div class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='tag' value='td'></div>Td</label>
						<label class='radio ib' style='margin: 0 15px'><div><input onchange='radio(this)' type='radio' name='tag' value='th'></div>Th</label>
					</form>
					<form>
						<label class='radio ib' style='margin: 0 15px'><div class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='create-or-update' value='both'></div>Для страниц \"Создать\" и \"Редактировать\"</label>
						<label class='radio ib' style='margin: 0 15px'><div><input onchange='radio(this)' type='radio' name='create-or-update' value='create'></div>Только \"Создать\"</label>
						<label class='radio ib' style='margin: 0 15px'><div><input onchange='radio(this)' type='radio' name='create-or-update' value='update'></div>Только \"Редактировать\"</label>
					</form>
					<br>
					<div class='panel' style='margin: 5px 50px'>
						<p>Атрибуты</p>
						<div>
							<table class='style attr mb10'>
								<tr>
									<th>Название</th>
									<th>Значение</th>
									<th></th>
								</tr>
								<tr>
									<td>
										<input type='text' name='name'>
									</td>
									<td>
										<input type='text' name='val'>
									</td>
									<td>
										<div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div>
									</td>
								</tr>
							</table>
							<div class='btn blue' onclick='functions.addAttr(this)'>Добавить</div>
						</div>
					</div>
					<br>
					<div class='panel' style='margin: 5px 50px 20px'>
						<p>Функция set: (data) -> &nbsp;&nbsp;<span style='color: #888'># data.rec - текущая запись, data.recs - все записи в коллекции tr</span></p>
						<div>
							<div class='ace-wrap'>
								<div id='ace-td-set' class='editor'></div>
							</div>
							<br>
							<div class='btn green' onclick='functions.addAttr(this)'>Сохранить функцию</div>
						</div>
					</div>
					<br>"
	ret += tab.gen
		'Html': ->
			"<div class='ace-wrap'>
				<div id='ace-td-html' class='editor'></div>
			</div>"
		'Поле': ->
			ret = "<label class='checkbox'><div><input type='checkbox' onchange='$(this).parents(\"label\").next().toggleClass(\"hidden\"); checkbox(this)'></div>Без заглавия</label>
			<label class='row mb10'><p>Заглавие</p><input type='text' name='header'></label>
			<label class='row mb10'><p>Поле</p><input type='text' name='field'></label>
			<label class='checkbox mb10'><div><input type='checkbox' name='format' onchange='$(this).parents(\"label\").next().toggleClass(\"hidden\"); checkbox(this)'></div>Формат</label>
			<div class='hidden'>"
			ret += tab.gen
				"Дата": ->
					"<label class='row'><p>Задать формат даты</p><input type='text' name='format-date'></label>"
			ret + "</div>
			<div class='panel' style='margin: 5px 50px'>
				<p>Атрибуты поля</p>
				<div>
					<table class='style field-attr mb10'>
						<tr>
							<th>Название</th>
							<th>Значение</th>
							<th></th>
						</tr>
						<tr>
							<td>
								<input type='text' name='name'>
							</td>
							<td>
								<input type='text' name='val'>
							</td>
							<td>
								<div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div>
							</td>
						</tr>
					</table>
					<div class='btn blue' onclick='functions.addAttr(this)'>Добавить</div>
				</div>
			</div>
			<label class='checkbox'><div><input onclick='$(this).parent().parent().next().toggleClass(\"hidden\"); checkbox(this)' type='checkbox' name='levelCb'></div>Указать уровень записи</label>
			<label class='row hidden'><p>Уровень записи</p><input type='text' name='level'></label>"
		'Выпадающий список': ->
			''
		'Выпадающее дерево': ->
			ret = "<label class='row mb10'><p>Заглавие</p><input type='text' name='header'></label>
			<label class='row mb10'><p>Поле</p><input type='text' name='field'></label>
			<form class='mb10'>
				<label class='radio ib'><div class='checked'><input type='radio' checked='checked' name='relation-type' value='belongs_to'></div>belongs_to</label>
				<label class='radio ib'><div><input type='radio' checked='checked' name='relation-type' value='has_many'></div>has_many</label>
			</form>
			<label class='row mb10'><p>Относится к модели</p><input type='text' name='relation-to'></label>
			<label class='row mb10'><p>Поле значения</p><input type='text' name='pick-val'></label>
			<label class='row mb10'><p>Поле заглавия</p><input type='text' name='pick-header'></label>
			<div class='panel'>
				<p>Структура моделей</p>
				<div>
					<div class='ace-wrap'>
						<div id='ace-td-treebox' class='editor'></div>
					</div>
				</div>
			</div>"
		'Показать поле': ->
			ret = "<form class='mb10'>
				<label class='radio ib'><div class='checked'><input onclick='$(this).parents(\"form\").next().addClass(\"hide\"); radio(this)' type='radio' checked='checked' name='show-model' value='current'></div>Эта модель</label>
				<label class='radio ib'><div><input onclick='$(this).parents(\"form\").next().removeClass(\"hide\"); radio(this)' type='radio' checked='checked' name='show-model' value='belongs_to'></div>belongs_to</label>
			</form>
			<label class='row hidden mb10'><p>Модель</p><input type='text' name='model'></label>
			<label class='row'><p>Выводить поле</p><input type='text' name='show'></label>"
			# list = []
			# list.push c.name for c in models[param.model].columns
			# dropdown.gen
			# 	list: list
			# 	name: 'show'
		'Чекбокс': ->
			''
		'Изображения': ->
			''
		'Table': ->
			'В <b>td</b> будет помещен <b>table</b>'
	ret += "</div>
			</div>
		</div>"
	for c in models[param.model].columns
		if c.name is "#{param.model}_id"
			ret += "<form class='mb10'><label class='radio ib' style='margin: 0 15px'><div class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='display-tree' value='none'></div>Выводить подряд</label>
			<label class='radio ib' style='margin: 0 15px'><div><input onchange='radio(this)' type='radio' name='display-tree' value='open-tree'></div>Показать открытым деревом</label>
			<label class='radio ib' style='margin: 0 15px'><div><input onchange='radio(this)' type='radio' name='display-tree' value='tree'></div>Показать закрытым деревом</label></form>"
		else if c.name is 'position'
			ret += "<form class='mb10'>
				<label class='radio ib' style='margin: 0 15px'><div class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='sortable' value='none'></div>Без возможности сортировки</label>
				<label class='radio ib' style='margin: 0 15px'><div><input onchange='radio(this)' type='radio' name='sortable' value='tree'></div>Сортировка деревом</label>
			</form>"
	ret += "<div id='order' class='dropdown mb10' onclick='dropdown.toggle(this)'>
			<p>Не сортировать</p>
			<div>
				<p class='active' data-val='none' onclick='dropdown.pick(this)'>Не сортировать</p>"
	for c in models[param.model].columns
		ret += "<p onclick='dropdown.pick(this)'>#{c.name}</p>"
	ret += "</div>
			<input type='hidden' value='none'>
		</div>
		<form class='mb10'>
			<label class='radio ib' style='margin: 0 15px'><div class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='order-type' value='asc'></div>asc</label>
			<label class='radio ib' style='margin: 0 15px'><div><input onchange='radio(this)' type='radio' name='order-type' value='desc'></div>desc</label>
		</form>
		<div class='panel'>
			<p>Загружать модели по belongs_to для записи</p>
			<div>
				<div class='ace-wrap'>
					<div id='ace-belongs-to' class='editor'></div>
				</div>
			</div>
		</div>
		<br>
		<div class='panel'>
			<p>Загружать модели по has_many для записи</p>
			<div>
				<div class='ace-wrap'>
					<div id='ace-has-many' class='editor'></div>
				</div>
			</div>
		</div>
		<br>
		<div class='panel'>
			<p>Переменные</p>
			<div>
				<div class='ace-wrap'>
					<div id='ace-vars' class='editor'></div>
				</div>
			</div>
		</div>
		<br>
		<div class='panel'>
			<p>Функции</p>
			<div>
				<div class='ace-wrap'>
					<div id='ace-functions' class='editor'></div>
				</div>
			</div>
		</div>
		<br>
	</div>
	<script src='/ace/ace.js'><\/script>"
app.after = ->
	template = app.templates.index[param.model]
	window.aceTrSet = ace.edit "ace-tr-set"
	aceTrSet.getSession().setMode "ace/mode/coffee"
	window.aceTdSet = ace.edit "ace-td-set"
	aceTdSet.getSession().setMode "ace/mode/coffee"
	window.aceBelongsTo = ace.edit "ace-belongs-to"
	aceBelongsTo.getSession().setMode "ace/mode/coffee"
	window.aceHasMany = ace.edit "ace-has-many"
	aceHasMany.getSession().setMode "ace/mode/coffee"
	window.aceVars = ace.edit "ace-vars"
	aceVars.getSession().setMode "ace/mode/coffee"
	window.aceFunctions = ace.edit "ace-functions"
	aceFunctions.getSession().setMode "ace/mode/coffee"
	window.aceTdHtml = ace.edit "ace-td-html"
	aceTdHtml.getSession().setMode "ace/mode/html"
	if template
		if template.belongs_to_plain
			aceBelongsTo.getSession().setValue template.belongs_to_plain
		if template.has_many_plain
			aceHasMany.getSession().setValue template.has_many_plain
		if template.vars_plain
			aceVars.getSession().setValue template.vars_plain
		if template.functions_plain
			aceFunctions.getSession().setValue template.functions_plain
app.functions =
	generateAsk: ->
		ask "<b>Создать шаблон?</b><br>Предыдущие данные будут удалены.",
			action: ->
				integers = []
				strings = []
				position = false
				has_self = false
				ret = ''
				for c in models[param.model].columns[1..-1]
					switch c.type
						when 'integer'
							integers.push c
						when 'string'
							strings.push c
				for c in integers
					if c.name is 'position'
						position = true
					else if c.name is "#{param.model}_id"
						has_self = true
				ret += "<table onclick='functions.pick(\"table\", this)'>"
				ret += "<tr onclick='functions.pick(\"tr\", this)'>"
				if position
					ret += "<td data-header='Переместить' data-attrs='{\"class\": \"sort-handler\", \"style\": \"width: 1px\"}' data-html='true'><div class='html hide'><div class='btn lightblue always'>[drag]</div></div><div class='btn lightblue always'>[drag]</div></td>"
				for c in strings
					header = c.name
					switch c.name
						when 'name'
							header = 'Название'
						when 'scode'
							header = 'Код'
					ret += "<td data-header='#{header}' data-show='#{c.name}'>#{header}</td>"
				if has_self
					ret += "<td data-header='Создать дочерний #{param.model}' data-attrs='{\"style\": \"width: 1%\"}'>
					Создать дочерний #{param.model}
					<div class='set hide'><!--(rec) -> @html = \"<a class='btn green always' onclick='app.aclick(this)' href='/admin/model/#{param.model}/new?#{param.model}_id=\#{rec.id}'><i class='icon-plus'></i></a>\"--></div>
					</td>"
				ret += "<td data-header='Редактировать' data-attrs='{\"style\": \"width: 1%\"}'>
				Редактировать
				<div class='set hide'><!--(rec) -> @html = \"<a class='btn orange always' onclick='app.aclick(this)' href='/admin/model/\#{param.model}/edit/\#{rec.id}'><i class='icon-pencil3'></i></a>\"--></div>
				</td>
				<td data-header='Удалить' data-attrs='{\"style\": \"width: 1%\"}'>
				Удалить
				<div class='set hide'><!--(rec) -> @html = \"<div class='btn red always' onclick='functions.removeRecord(this)'><i class='icon-remove3'></i></div>\"--></div>
				</td>"
				ret += "</tr>"
				ret += "</table>"
				$('#table-structure').html ret
				if has_self
					r = $("[name='display-tree'][value='open-tree']")
					r.parents('form').eq(0).find('input').each ->
						el = $ @
						if el.val() is 'open-tree'
							el.prop 'checked', true
							el.parent().addClass 'checked'
						else
							el.prop 'checked', false
							el.parent().removeClass 'checked'
				if position
					r = $("[name='sortable'][value='tree']")
					r.parents('form').eq(0).find('input').each ->
						el = $ @
						if el.val() is 'tree'
							el.prop 'checked', true
							el.parent().addClass 'checked'
						else
							el.prop 'checked', false
							el.parent().removeClass 'checked'
					order = $('#order')
					order.find('> p').html 'position'
					order.find('> div > p').each ->
						el = $ @
						if el.html() is 'position'
							el.addClass 'active'
						else
							el.removeClass 'active'
					order.find('input').val 'position'
					r = $("[name='order-type'][value='asc']")
					r.parents('form').eq(0).find('input').each ->
						el = $ @
						if el.val() is 'asc'
							el.prop 'checked', true
							el.parent().addClass 'checked'
						else
							el.prop 'checked', false
							el.parent().removeClass 'checked'
			ok:
				html: 'Создать'
				class: 'green'
	save: ->
		addTab = (str) ->
			str.replace /\n/g, "\n\t"
		attrsGen = (data) ->
			if data.attrs
				ret = "\n\tattrs:"
				for k, v of data.attrs
					ret += "\n\t\t#{k}: \"#{v}\""
				ret
			else
				""
		genTable = (el) ->
			data = el.data()
			table = "\n{" + attrsGen data
			trs = []
			el.find('> tbody > tr').each ->
				el = $ @
				data = el.data()
				tr = "\n{" + attrsGen data
				set = el.find '> .set'
				if set.length
					set = set.text()
					tr += "\n\tset: #{addTab set}\n\tsetPlain: " + JSON.stringify(set).replace /#{/g, '\\#{'
				tds = []
				el.find('> td').each ->
					el = $ @
					unless el.hasClass 'hidden'
						data = el.data()
						td = "\n{" + attrsGen data
						td += "\n\theader: \"#{data.header}\"" if data.header
						td += "\n\tshow: \"#{data.show}\"" if data.show
						if data.format
							td += "\n\tformat:"
							for k, v of data.format
								td += "\n\t\t#{k}: \"#{v}\""
						if data.html
							td += "\n\thtml: " + JSON.stringify el.find('> .html').html()
						if data.table
							tables = []
							el.find('> table').each ->
								tables.push genTable $ @
							td += "\n\ttable: [#{tables.join(',').replace(/\n/g,"\n\t\t")}\n\t]"
						td += "\n\tth: true" if data.th
						set = el.find '> .set'
						if set.length
							set = set.html()[4..-4]
							td += "\n\tset: #{addTab set}\n\tsetPlain: " + JSON.stringify(set).replace /#{/g, '\\#{'
						tds.push td + "\n}"
				tr += "\n\ttd: [#{tds.join(',').replace(/\n/g, "\n\t\t")}\n\t]" if tds.length
				tr += "\n}"
				trs.push tr
			if trs.length
				table += "\n\ttr: [#{trs.join(',').replace(/\n/g,"\n\t\t")}\n\t]"
			table + "\n}"
		tables = []
		$("#table-structure > table").each ->
			tables.push genTable($ @).replace /\n/g, "\n\t\t"
		file = "app.templates.index.#{param.model} =\n\ttable: [#{tables.join ','}\n\t]"
		belongs_to = aceBelongsTo.getValue()
		unless belongs_to is ''
			file += "\n\tbelongs_to: #{$.trim belongs_to.replace(/\ {2}/g, "\t").replace(/\n/g, "\n\t\t")}\n\tbelongs_to_plain: " + JSON.stringify(belongs_to).replace /#{/g, '\\#{'
		has_many = aceHasMany.getValue()
		unless has_many is ''
			file += "\n\thas_many: #{$.trim has_many.replace(/\ {2}/g, "\t").replace(/\n/g, "\n\t\t")}\n\thas_many_plain: " + JSON.stringify(has_many).replace /#{/g, '\\#{'
		vars = aceVars.getValue()
		unless vars is ''
			file += "\n\tvars:\n\t\t#{$.trim vars.replace(/\ {2}/g, "\t").replace(/\n/g, "\n\t\t")}\n\tvars_plain: " + JSON.stringify(vars).replace /#{/g, '\\#{'
		functions = aceFunctions.getValue()
		unless functions is ''
			file += "\n\tfunctions:\n\t\t#{functions.replace(/\n/g, "\n\t\t")}\n\tfunctions_plain: " + JSON.stringify(functions).replace /#{/g, '\\#{'
		$("[name='display-tree']").each ->
			file += "\n\tdisplay: \"#{@.value}\"" if @.checked and @.value isnt 'none'
		$("[name='sortable']").each ->
			file += "\n\tsortable: \"#{@.value}\"" if @.checked and @.value isnt 'none'
		order = $('#order > p').html()
		unless order is 'Не сортировать'
			file += "\n\torder: #{order}: \"#{$(".checked [name='order-type']").val()}\""
		post "write", path: "app/assets/javascripts/admin/templates/#{param.model}/index.coffee", file: file, ->
			notify "Страница записей обновлена"