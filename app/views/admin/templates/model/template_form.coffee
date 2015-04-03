app.page = ->
	model = models[param.model]
	template = app.templates.form[param.model]
	ret = "<h1>Форма <b>#{param.model}</b></h1>
	<div class='content'>
		<div class='btn green m15' onclick='functions.save()'>Сохранить</div>
		<div class='btn purple' onclick='functions.generateAsk()'>Создать автоматически</div>
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
				ret += " data-images='true'" if td.images
				ret += " data-level='#{td.level}'" if td.level or td.level is 0
				ret += " data-validation='#{JSON.stringify td.validation}'" if td.validation
				ret += " data-checkbox='#{td.checkbox}'" if td.checkbox
				ret += " data-image='#{td.image}'" if td.image
				ret += " data-text='#{JSON.stringify td.text}'" if td.text
				if td.attrs
					ret += " data-attrs='#{JSON.stringify td.attrs}'"
					for k, v of td.attrs
						ret += " #{k}='#{v}'" unless k in ['class', 'onclick']
				if td.fieldAttrs
					ret += " data-field-attrs='#{td.fieldAttrs}'"
					for k, v of td.fieldAttrs
						ret += " #{k}='#{v}'" unless k in ['class', 'onclick']
				ret += ">"
				if td.table
					ret += drawTable tdt for tdt in td.table
				else
					ret += "<div>"
					if td.html
						ret += td.html
					else if td.header
						ret += td.header
					else if td.field
						ret += td.field
					else if td.show
						ret += td.show
					else if td.set
						ret += "* функция *"
					else if td.text
						descs = []
						descs.push n for n of td.text
						ret += "Текст: #{descs.join ', '}"
					else if td.images
						ret += "Изображения"
					else if td.checkbox
						ret += td.checkbox
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
							if v.has_self
								ret += "\n\thas_self: true"
						ret += "</div>"
					ret += "<div class='set hide'>#{td.setPlain}</div>" if td.setPlain
				ret += "</td>"
			ret += "</tr>"
		ret + "</table>"
	if template
		ret += drawTable t for t in template.table
	else
		ret += "<table onclick='functions.pick(\"table\", this)'>
			<tr onclick='functions.pick(\"tr\", this)'>
				<td onclick='functions.pick(\"td\", this)' data-html='true'>
					<div>Новая ячейка</div>
				</td>
			</tr>
		</table>"
	ret += "</div>
		<div id='panels'>
			<div class='panel red hide'>
				<p>Table</p>
				<div>
					<div class='btn green mb10' onclick='functions.saveTable()'>Сохранить</div>
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
					<div class='btn green mb10' onclick='functions.saveTr()'>Сохранить</div>
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
					<div class='btn green mb10' onclick='functions.saveTd()'>Сохранить</div>
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
			<label class='checkbox mb10'><div><input type='checkbox' name='validation' onchange='$(this).parents(\"label\").next().toggleClass(\"hidden\"); checkbox(this)'></div>Валидация</label>
			<div class='hidden panel'>
				<p>Валидация</p>
				<div id='validation-wrap'>
					<label class='checkbox mb10'><div><input type='checkbox' name='presence' onchange='checkbox(this)'></div>Не пустое</label><br>
					<label class='checkbox mb10'><div><input type='checkbox' name='uniq' onchange='checkbox(this)'></div>Уникальное</label>
				</div>
			</div>
			<br>
			<label class='checkbox mb10'><div><input type='checkbox' name='format' onchange='$(this).parents(\"label\").next().toggleClass(\"hidden\"); checkbox(this)'></div>Формат</label>
			<div class='hidden format-tabs mb10'>"
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
		'Чекбокс': ->
			"<label class='row mb10'><p>Заглавие</p><input type='text' name='header'></label>
			<label class='row mb10'><p>Поле</p><input type='text' name='checkbox'></label>"
		'Изображения': ->
			"<label class='row mb10'><p>Надпись на кнопке</p><input type='text' name='header'></label>
			<form class='mb10'>
				<label class='radio ib' style='margin: 0 15px'><div class='checked'><input checked='checked' onchange='$(this).parents(\"form\").eq(0).next().fadeIn(300); radio(this)' type='radio' name='image-count' value='one'></div>Одно изображение</label>
				<label class='radio ib' style='margin: 0 15px'><div><input onchange='$(this).parents(\"form\").eq(0).next().fadeOut(300); radio(this)' type='radio' name='image-count' value='many'></div>Множество изображений</label>
			</form>
			<label class='row mb10'><p>Поле</p><input type='text' name='image'></label>"
		'Текст': ->
			"<table class='style mb10'>
				<tr>
					<th>Название вкладки</th>
					<th>Поле</th>
					<th>Тип</th>
					<th></th>
				</tr>
				<tr>
					<td>
						<input type='text' name='header'>
					</td>
					<td>
						<input type='text' name='field'>
					</td>
					<td>
						<form>
							<label class='radio ib' style='margin: 0 15px'><div style='vertical-align: top' class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='type' value='editor'></div>Редактор TinyMCE</label>
							<label class='radio ib' style='margin: 0 15px'><div style='vertical-align: top'><input onchange='radio(this)' type='radio' name='type' value='textarea'></div>Textarea</label>
						</form>
					</td>
					<td>
						<div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div>
					</td>
				</tr>
			</table>
			<div class='btn blue' onclick='functions.addText(this)'>Добавить</div>"
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
app.functions =
	add: (tag, action) ->
		$('#current')[action] "<#{tag} onclick='functions.pick(\"#{tag}\", this)'#{if tag is 'td' then "data-html='true'><div>Новая ячейка</div>" else ">"}</#{tag}>"
	remove: (el) ->
		$(el).parents('.panel').addClass 'hide'
		$('#current').remove()
	addAttr: (el) ->
		$(el).prev().append "<tr><td><input type='text' name='name'></td><td><input type='text' name='val'></td><td><div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div></td></tr>"
	addText: (el) ->
		$(el).prev().append "<tr><td><input type='text' name='header'></td><td><input type='text' name='field'></td><td><form><label class='radio ib' style='margin: 0 15px'><div style='vertical-align: top' class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='type' value='editor'></div>Редактор TinyMCE</label><label class='radio ib' style='margin: 0 15px'><div style='vertical-align: top'><input onchange='radio(this)' type='radio' name='type' value='textarea'></div>Textarea</label></form></td><td><div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div></td></tr>"
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
					openTab nav.find('p')[2]
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
					if data.validation
						wrap = tab.find("[name='validation']").prop('checked', true).parent().addClass('checked').parent().next().removeClass('hidden')
						if data.validation.presence
							checkbox wrap.find("[name='presence']").prop('checked', true)[0]
						if data.validation.uniq
							checkbox wrap.find("[name='uniq']").prop('checked', true)[0]
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
					openTab nav.find('p')[3]
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
				else if data.checkbox
					openTab nav.find('p')[4]
					tab = panel.find '.tabs > .active'
					tab.find("[name='header']").val data.header if data.header
					tab.find("[name='checkbox']").val data.checkbox
				else if data.image
					openTab nav.find('p')[5]
					tab = panel.find '.tabs > .active'
					tab.find("[name='header']").val data.header if data.header
					radio tab.find("[name='image-count'][value='one']").prop('checked', true)[0]
					tab.find("[name='image']").val(data.image).parents('label').show(300)
				else if data.text
					openTab nav.find('p')[6]
					ret = "<tr><th>Название вкладки</th><th>Поле</th><th>Тип</th><th></th>"
					for k, v of data.text
						ret += "<tr><td><input type='text' name='header' value='#{k}'><td><input type='text' name='field' value='#{v.field}'></td><td><form><label class='radio ib' style='margin: 0 15px'><div style='vertical-align: top' "
						if v.type is 'editor'
							ret += "class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='type' value='editor'></div>Редактор TinyMCE</label><label class='radio ib' style='margin: 0 15px'><div style='vertical-align: top'><input onchange='radio(this)' type='radio' name='type' value='textarea'></div>Textarea</label>"
						else
							ret += "><input onchange='radio(this)' type='radio' name='type' value='editor'></div>Редактор TinyMCE</label><label class='radio ib' style='margin: 0 15px'><div style='vertical-align: top' class='checked'><input checked='checked' onchange='radio(this)' type='radio' name='type' value='textarea'></div>Textarea</label>"
						ret += "</form></td><td><div class='btn red' onclick='$(this).parents(\"tr\").remove()'>Удалить</div></td></tr>"
					panel.find('.tabs > .active > table').html ret
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
						td += "\n\tcheckbox: \"#{data.checkbox}\"" if data.checkbox
						td += "\n\tlevel: \"#{data.level}\"" if data.level
						td += "\n\timages: true" if data.images
						td += "\n\timage: '#{data.image}'" if data.image
						if data.fieldAttrs
							td += "\n\tfieldAttrs:"
							for k, v of JSON.parse data.fieldAttrs
								td += "\n\t\t#{k}: \"#{v}\""
						treebox = el.find '.treebox'
						if treebox.length
							td += "\n\ttreebox:\n\t\tdata:\n\t\t\t" + treebox.html().replace(/\n/g, "\n\t\t\t").replace(/^\s\s/, "\t")
							tb_data = treebox.data()
							td += "\n\t\tpick:" if tb_data.pickVal or tb_data.pickHeader
							td += "\n\t\t\tval: \"#{tb_data.pickVal}\"" if tb_data.pickVal
							td += "\n\t\t\theader: \"#{tb_data.pickHeader}\"" if tb_data.pickHeader
						if data.validation
							td += "\n\tvalidation:"
							for k, v of data.validation
								td += "\n\t\t#{k}: #{v}"
						if data.format
							td += "\n\tformat:"
							for k, v of JSON.parse data.format
								td += "\n\t\t#{k}: \"#{v}\""
						if data.html
							td += "\n\thtml: "
							el.find('> div').each ->
								html = $ @
								unless html.hasClass('hidden') or html.hasClass('hide')
									td += JSON.stringify html.html()
						if data.text
							td += "\n\ttext: "
							for header, v of data.text
								td += "\n\t\t\"#{header}\":\n\t\t\tfield: \"#{v.field}\"\n\t\t\ttype: \"#{v.type}\""
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
		post "write", path: "app/assets/javascripts/admin/templates/#{param.model}/form.coffee", file: file, ->
			notify "Форма обновлена"
	generateAsk: ->
		ask "<b>Создать шаблон?</b><br>Предыдущие данные будут удалены.",
			action: ->
				integers = []
				strings = []
				texts = []
				ret = ''
				for c in models[param.model].columns[1..-1]
					switch c.type
						when 'integer'
							integers.push c
						when 'string'
							strings.push c
						when 'text'
							texts.push c
				belongs_to = []
				for c in integers
					if c.name[-3..-1] is '_id'
						belongs_to.push c
				ret += "<table onclick='functions.pick(\"table\", this)'>"
				for c in belongs_to
					field_name = c.name
					name = c.name[0..-4]
					cols = models[name].columns
					pick = false
					has_self = false
					for c in cols
						if c.name is 'name'
							pick = 'name'
						else if c.name is field_name
							has_self = true
					unless pick
						for c in cols
							if c.name is 'scode'
								pick = 'scode'
								break
						unless pick
							for c in cols
								if c.type is 'string'
									pick = c.name
									break
							pick = 'id' unless pick
					ret += "<tr onclick='functions.pick(\"tr\", this)'>
						<td onclick='functions.pick(\"td\", this)'
						data-field='#{field_name}'
						data-header='#{name}'
						data-belongs_to='#{name}'"
					ret += " data-has_self='true'" if has_self
					ret += ">
							<div>#{name}</div>
							<div data-pick-val='id'
							data-pick-header='#{pick}'
							class='hide treebox'>#{name}:\n\tfields: ['#{pick}']\n\tpick: true"
					ret += "\n\thas_self: true" if has_self
					ret += "</div>
						</td>
					</tr>"
				for c in integers
					unless c.name is 'position' or c.name[-3..-1] is '_id'
						ret += "<tr onclick='functions.pick(\"tr\", this)'><td data-header='#{c.name}' data-field='#{c.name}'><div>#{c.name}</div></td></tr>"
				for c in strings
					if c.name is 'image'
						ret += "<tr onclick='functions.pick(\"tr\", this)'><td onclick='functions.pick(\"td\", this)' data-header='Добавить изображение' data-image='image'><div>Добавить изображение заголовка</div></td></tr>"
					else
						ret += "<tr onclick='functions.pick(\"tr\", this)'><td onclick='functions.pick(\"td\", this)' data-header='#{c.name}' data-field='#{c.name}'><div>#{c.name}</div></td></tr>"
				if 'images' in models[param.model].has_many
					ret += "<tr><td data-images='true' onclick='functions.pick(\"td\", this)'><div>Изображения</div></td></tr>"
				if texts.length
					descs = []
					descs.push c.name for c in texts
					jdescs = {}
					for c in texts
						if c.name is "seo_descriptions"
							type = "textarea"
						else type = "editor"
						jdescs[c.name] = field: c.name, type: type
					ret += "<tr><td data-images='true' onclick='functions.pick(\"td\", this)' data-text='#{JSON.stringify jdescs}'><div>Текст: #{descs.join ', '}</div></td></tr>"
				ret += "</table>"
				$('#table-structure').html ret
				if belongs_to.length
					belongs_to_plain = []
					for c in belongs_to
						belongs_to_plain.push "\n\t{model: \"#{c.name[0..-4]}\"}"
					aceBelongsTo.getSession().setValue "[" + belongs_to_plain.join(',') + "\n]"
			ok:
				html: 'Создать'
				class: 'green'
	saveTd: ->
		el = $ '#current' # Текущая ячейка
		for a in el[0].attributes # Убираем аттрибуты, чтобы потом добавить новые
			if a and a.name not in ['onclick', 'id'] and a.name[0..4] isnt 'data-'
				el.removeAttr a.name
		panel = $ '.panel.blue'
		el.removeData()
		ret = ""
		el.data 'th', true if panel.find("[name='tag'][value='th']")[0].checked # Если тэг th
		switch panel.find("[name='create-or-update']:checked").val() # Для каких типов страниц
			when 'create'
				el.data 'only', 'create'
			when 'update'
				el.data 'only', 'update'
		attrs = {} # Установка атрибутов ячейки
		addAttrs = false
		panel.find('.attr tr').each ->
			tr = $ @
			name = tr.find("[name='name']").val()
			val = tr.find("[name='val']").val()
			if name isnt '' and name? and val isnt '' and val?
				addAttrs = true
				attrs[name] = val
		if addAttrs
			el.data 'attrs', attrs
			for k, v of attrs
				el.attr k, v unless k in ['class', 'onclick']
		set = aceTdSet.getValue() # Добавляем функцию ячейки
		unless set is ''
			ret += "<div>* функция *</div><div class='set hide'>#{set}</div>"
		switch panel.find('> div > .nav-tabs > .active').html() # Поиск текущего типа ячейки
			when 'Html'
				html = aceTdHtml.getValue()
				unless html is ''
					el.data 'html', true
					ret = "<div>#{html}</div>"
			when 'Поле'
				div = panel.find('> div > .tabs > .active')
				header = div.find("[name='header']").val() # Заглавие
				unless header is ''
					el.data 'header', header
					ret = "<div>#{header}</div>"
				field = div.find("[name='field']").val() # Поле
				el.data 'field', field
				ret = "<div>#{field}</div>" if header is ''
				if div.find("[name='validation']")[0].checked # Валидация
					wrap = $ '#validation-wrap'
					validation = {}
					validation.presence = true if wrap.find("[name='presence']")[0].checked
					validation.uniq = true if wrap.find("[name='uniq']")[0].checked
					el.data 'validation', validation
				if div.find("[name='format']")[0].checked # Формат
					switch div.find('.format-tabs > .nav-tabs > .active').html()
						when 'Дата'
							formatDate = div.find("[name='format-date']").val()
							unless formatDate is ''
								el.data 'format', {date: formatDate}
				attrs = {} # Установка атрибутов поля
				addAttrs = false
				div.find('.field-attr tr').each ->
					tr = $ @
					name = tr.find("[name='name']").val()
					val = tr.find("[name='val']").val()
					if name isnt '' and name? and val isnt '' and val?
						addAttrs = true
						attrs[name] = val
				if addAttrs
					el.data 'fieldAttrs', attrs
					for k, v of attrs
						el.attr k, v unless k in ['class', 'onclick']
				level = div.find("[name='level']").val() # Установка уровня записи
				el.data 'level', level unless level is ''
			when 'Выпадающий список'
				div = panel.find('> div > .tabs > .active')
				header = div.find("[name='header']").val() # Заглавие
				field = div.find("[name='field']").val() # Поле
				relationType = div.find("[name='relation-type']:checked").val() # Тип отношения
				relationTo = div.find("[name='relation-to']").val() # Относится к
				pickVal = div.find("[name='pick-val']").val() # Поля значения
				pickHeader = div.find("[name='pick-header']").val() # Поля заглавия
				el.data 'field', field
				if relationType is 'belongs_to'
					el.data 'belongs_to', relationTo
				else if relationType is 'has_many'
					el.data 'has_many', relationTo
				if header isnt ''
					el.data 'header', header
					ret += "<div>#{header}</div>"
				else if relationTo isnt ''
					ret += "<div>#{relationTo}</div>"
				else ret += "<div>#{field}</div>"
				ret += "<div"
				ret += " data-pick-val='#{pickVal}'" if pickVal
				ret += " data-pick-header='#{pickHeader}'" if pickHeader
				ret += " class='hide treebox'>#{aceTdTreebox.getValue()}</div>"
			when 'Чекбокс'
				div = panel.find('> div > .tabs > .active')
				header = div.find("[name='header']").val() # Заглавие
				field = div.find("[name='checkbox']").val() # Чекбокс
				el.data 'checkbox', field
				if header is ''
					ret += "<div>#{field}</div>"
				else
					el.data 'header', header
					ret += "<div>#{header}</div>"
			when 'Изображения'
				div = panel.find('> div > .tabs > .active')
				header = div.find("[name='header']").val() # Надпись на кнопке
				count = div.find("[name='image-count']:checked").val()
				if count is 'one'
					image = div.find("[name='image']").val()
					el.data 'image', image
					header = "Добавить изображение " + image if header is ''
				else
					el.data "images", true
					header = "Добавить изображения" if header is ''
				el.data 'header', header
				ret +=  "<div>#{header}</div>"
			when 'Текст'
				text = {}
				panel.find('> div > .tabs > .active > table tr').each ->
					tr = $ @
					unless tr.find('th').length
						header = tr.find("[name='header']").val()
						field = tr.find("[name='field']").val()
						if header isnt '' or field isnt ''
							type = tr.find("[name='type']:checked").val()
							text[header] = field: field, type: type
				el.data 'text', text
				ret = '<div>Текст</div>'
		el.html ret
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