app.page = ->
	model = models[param.model]
	template = model.templates.form
	ret = "<h1>Форма <b>#{param.model}</b></h1>
	<div class='content'>
		<div class='btn green m15' onclick='functions.save()'>Сохранить</div>
		<div id='table-structure'>"
	drawTable = (t) ->
		ret = "<table onclick='functions.pick(\"table\", this)'"
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
			if tr.collection
				ret += " data-collection-type='#{tr.collection.type}'" if tr.collection.type
				ret += " data-collection-model='#{tr.collection.model}'" if tr.collection.model
			ret += ">"
			ret += "<td class='set hidden'>#{tr.setPlain}</td>" if tr.setPlain
			for td in tr.td
				ret += "<td onclick='functions.pick(\"td\", this)'"
				ret += " class='table-wrap' data-table='true'" if td.table
				ret += " data-field='#{td.field}'" if td.field
				ret += " data-header='#{td.header}'" if td.header
				ret += " data-belongs_to='#{td.belongs_to}'" if td.belongs_to
				ret += " data-format='#{JSON.stringify td.format}'" if td.format
				ret += " data-html='true'" if td.html
				ret += " data-show='#{td.show}'" if td.show
				ret += " data-only='#{td.only}'" if td.only
				ret += " data-th='true'" if td.th
				ret += " data-level='#{td.level}'" if td.level or td.level is 0
				if td.attrs
					ret += " data-attrs='#{JSON.stringify td.attrs}'"
					for k, v of td.attrs
						ret += " #{k}='#{v}'" unless k in ['class', 'onclick']
				if td.fieldAttrs
					ret += " data-field-attrs='#{JSON.stringify td.fieldAttrs}'"
					for k, v of td.fieldAttrs
						ret += " #{k}='#{v}'" unless k in ['class', 'onclick']
				ret += ">"
				if td.table
					ret += drawTable tdt for tdt in td.table
				else
					ret += "<div>"
					if td.header
						ret += td.header
					else if td.field
						ret += td.field
					else if td.show
						ret += td.show
					else if td.html
						ret += td.html
					else if td.set
						ret += "* функция *"
					else
						ret += "&nbsp;"
					ret += "</div>"
					if td.treebox
						ret += "<div"
						if td.treebox.pick
							ret += " data-pick-val='#{td.treebox.pick.val}'" if td.treebox.pick.val
							ret += " data-pick-header='#{td.treebox.pick.header}'" if td.treebox.pick.header
						ret += " class='hide treebox'>"
						first = true
						for k, v of td.treebox.data
							if first
								first = false
							else
								ret += "\n"
							ret += k + ":"
							if v.fields
								fields = []
								fields.push "'#{f}'" for f in v.fields
								ret += "\n\tfields: [#{fields.join ','}]"
							if v.pick
								ret += "\n\tpick: true"
						ret += "</div>"
					ret += "<div class='set hide'>#{td.setPlain}</div>" if td.setPlain
				ret += "</td>"
			ret += "</tr>"
		ret + "</table>"
	ret += drawTable t for t in template.table
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
	ret + "</div>
			</div>
		</div>
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
window.functions =
	add: (tag, action) ->
		$('#current')[action] "<#{tag} onclick='functions.pick(\"#{tag}\", this)'></#{tag}>"
	remove: (el) ->
		$(el).parents('.panel').addClass 'hide'
		$('#current').remove()
	addAttr: (el) ->
		$(el).prev().append "<tr><td><input type='text' name='name'></td><td><input type='text' name='val'></td><td><div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div></td></tr>"
	trCollection: (el) ->
		checkbox el
		$(el).parents('label').next().toggleClass 'hide'
	pick: (tag, el) ->
		el = $ el
		$('#current').attr 'id', ''
		el.attr 'id', 'current'
		panels = $('#panels')
		panels.find('> .panel').addClass 'hide'
		data = el.data()
		set = []
		switch tag
			when 'table'
				panel = panels.find('> .red').removeClass 'hide'
			when 'tr'
				panel = panels.find('> .green').removeClass 'hide'
				set = el.find('> .set')
				aceTrSet.getSession().setValue set.text() if set.length > 0
				collectionCB = panel.find "[name='collection']"
				if data.collectionType or data.collectionModel
					collection = collectionCB.prop('checked', true).parent().addClass('checked').parent().next().removeClass 'hide'
					collection.find("[name='collection-type']").val data.collectionType if data.collectionType
					collection.find("[name='collection-model']").val data.collectionModel if data.collectionModel
				else
					collectionCB.prop('checked', false).parent().removeClass('checked').parent().next().addClass 'hide'
			when 'td'
				panel = panels.find('> .blue').removeClass 'hide'
				nav = panel.find '.nav-tabs'
				treebox = el.find '.treebox'
				div = el.find '> div'
				if treebox.length > 0
					openTab nav.find('p')[3]
					tab = panel.find '.tabs > .active'
					tab.find("[name='header']").val data.header if data.header
					tab.find("[name='field']").val data.field if data.field
					if data.belongs_to
						tab.find("[name='relation-type']").each ->
							r = $(@)
							if r.val() is 'belongs_to'
								r.prop 'checked', true
								r.parent().addClass 'checked'
							else
								r.prop 'checked', false
								r.parent().removeClass 'checked'
						tab.find("[name='relation-to']").val data.belongs_to
					pick = treebox.data()
					tab.find("[name='pick-val']").val pick.pickVal if pick.pickVal
					tab.find("[name='pick-header']").val pick.pickHeader if pick.pickHeader
					aceTdTreebox.getSession().setValue treebox.html()
				else if data.field
					openTab nav.find('p')[1]
					tab = panel.find '.tabs > .active'
					tab.find("[name='header']").val data.header if data.header
					tab.find("[name='field']").val data.field
					if data.format
						format = tab.find("[name='format']").prop('checked', true).parent().addClass('checked').parent().next().removeClass('hidden')
						if data.format.date
							openTab format.find('.nav-tabs p').get 0
							format.find("[name='format-date']").val data.format.date
					else
						tab.find("[name='format']").prop('checked', false).parent().removeClass('checked').parent().next().addClass('hidden').find('input').val ''
					attrs = data.fieldAttrs
					if attrs
						ret = "<tr><th>Название</th><th>Значение</th><th></th></tr>"
						for k, v of attrs
							ret += "<tr>
								<td><input type='text' name='name' value='#{k}'></td>
								<td><input type='text' name='val' value='#{v}'></td>
								<td><div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div></td>
							</tr>"
						panel.find('.field-attr').html ret
					if data.level or data.level is 0
						tab.find("[name='levelCb']").prop('checked', true).parent().addClass('checked').parent().next().removeClass('hidden').find('input').val data.level
					else
						tab.find("[name='levelCB']").prop('checked', false).parent().removeClass('checked').parent().next().addClass 'hidden'
				else if data.html
					openTab nav.find('p')[0]
					aceTdHtml.getSession().setValue div.html()
				else if data.show
					openTab nav.find('p')[4]
					tab = panel.find '.tabs > .active'
					tab.find("[name='show']").val data.show
					if data.belongs_to
						tab.find("[name='model']").val data.belongs_to
						m = 'belongs_to'
					else
						m = 'current'
					tab.find("[name='show-model']").each ->
						a = $(@)
						if a.val() is m
							label = a.prop('checked', true).parent().addClass('checked').parents('form').next()
							if m is 'current'
								label.addClass 'hidden'
							else
								label.removeClass 'hidden'
						else
							a.prop('checked', false).parent().removeClass('checked').parent().next()
				else if data.table
					openTab nav.find('p')[7]
				data.only ?= 'both'
				panel.find("[name='create-or-update']").each ->
					r = $ @
					if r.val() is data.only
						r.prop('checked', true).parent().addClass('checked')
					else
						r.prop('checked', false).parent().removeClass('checked')
				if data.tag
					data.tag = 'th'
				else data.tag = 'td'
				panel.find("[name='tag']").each ->
					r = $ @
					if r.val() is data.tag
						r.prop('checked', true).parent().addClass('checked')
					else
						r.prop('checked', false).parent().removeClass('checked')
				set = el.find('> .set')
				aceTdSet.getSession().setValue set.text() if set.length > 0
		attrs = data.attrs
		if attrs
			ret = "<tr><th>Название</th><th>Значение</th><th></th></tr>"
			for k, v of attrs
				ret += "<tr>
					<td><input type='text' name='name' value='#{k}'></td>
					<td><input type='text' name='val' value='#{v}'></td>
					<td><div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div></td>
				</tr>"
			panel.find('.attr').html ret
		event.stopPropagation()
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
				if data.collectionType or data.collectionModel
					tr += "\n\tcollection:"
					tr += "\n\t\ttype: \"#{data.collectionType}\"" if data.collectionType
					tr += "\n\t\tmodel: \"#{data.collectionModel}\"" if data.collectionModel
				tds = []
				el.find('> td').each ->
					el = $ @
					unless el.hasClass 'hidden'
						data = el.data()
						td = "\n{" + attrsGen data
						td += "\n\theader: \"#{data.header}\"" if data.header
						td += "\n\tfield: \"#{data.field}\"" if data.field
						td += "\n\tbelongs_to: \"#{data.belongs_to}\"" if data.belongs_to
						td += "\n\tonly: \"#{data.only}\"" if data.only
						td += "\n\tshow: \"#{data.show}\"" if data.show
						td += "\n\tlevel: \"#{data.level}\"" if data.level
						if data.fieldAttrs
							td += "\n\tfieldAttrs:"
							for k, v of data.fieldAttrs
								td += "\n\t\t#{k}: \"#{v}\""
						treebox = el.find '.treebox'
						if treebox.length
							td += "\n\ttreebox:\n\t\tdata:\n\t\t\t" + treebox.html().replace(/\n/g, "\n\t\t\t").replace(/^\s\s/, "\t")
							tb_data = treebox.data()
							td += "\n\t\tpick:" if tb_data.pickVal or tb_data.pickHeader
							td += "\n\t\t\tval: \"#{tb_data.pickVal}\"" if tb_data.pickVal
							td += "\n\t\t\theader: \"#{tb_data.pickHeader}\"" if tb_data.pickHeader
						if data.format
							td += "\n\tformat:"
							for k, v of data.format
								td += "\n\t\t#{k}: \"#{v}\""
						if data.html
							td += "\n\thtml: "
							el.find('> div').each ->
								html = $ @
								unless html.hasClass('hidden') or html.hasClass('hide')
									td += JSON.stringify html.html()
						if data.table
							tables = []
							el.find('> table').each ->
								tables.push genTable $ @
							td += "\n\ttable: [#{tables.join(',').replace(/\n/g,"\n\t\t")}\n\t]"
						td += "\n\tth: true" if data.th
						set = el.find '> .set'
						if set.length
							set = set.text()
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
		file = "app.templates.form.#{param.model} =\n\ttable: [#{tables.join ','}\n\t]"
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
		post "write", path: "app/assets/javascripts/admin/models/#{param.model}/form.coffee", file: file, ->
			notify "Форма обновлена"
app.after = ->
	model = models[param.model]
	template = model.templates.form
	window.aceTrSet = ace.edit "ace-tr-set"
	aceTrSet.getSession().setMode "ace/mode/coffee"
	window.aceTdSet = ace.edit "ace-td-set"
	aceTdSet.getSession().setMode "ace/mode/coffee"
	window.aceTdTreebox = ace.edit "ace-td-treebox"
	aceTdTreebox.getSession().setMode "ace/mode/coffee"
	window.aceBelongsTo = ace.edit "ace-belongs-to"
	aceBelongsTo.getSession().setMode "ace/mode/coffee"
	if template.belongs_to_plain
		aceBelongsTo.getSession().setValue template.belongs_to_plain
	window.aceHasMany = ace.edit "ace-has-many"
	aceHasMany.getSession().setMode "ace/mode/coffee"
	if template.has_many_plain
		aceHasMany.getSession().setValue template.has_many_plain
	window.aceVars = ace.edit "ace-vars"
	aceVars.getSession().setMode "ace/mode/coffee"
	if template.vars_plain
		aceVars.getSession().setValue template.vars_plain
	window.aceFunctions = ace.edit "ace-functions"
	aceFunctions.getSession().setMode "ace/mode/coffee"
	if template.functions_plain
		aceFunctions.getSession().setValue template.functions_plain
	window.aceTdHtml = ace.edit "ace-td-html"
	aceTdHtml.getSession().setMode "ace/mode/html"