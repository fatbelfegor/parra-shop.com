app.page = ->
	model = app.data.route.model
	table = tables[model]
	id = app.data.route.id
	# if app.data.record
	for r in table.records
		if r.record.id is parseInt id
			rec = r
	ret = "<h1 class='title'>#{if id then 'Редактировать запись' else 'Добавить запись'} <b>#{model}</b></h1>
	<div class='content'>
		<form data-table='#{table.singularize}' action='model/#{if id then "#{table.singularize}/update" else "#{table.singularize}/create"}'>
			<div class='btn green dashed' onclick='tinyMCE.triggerSave(); record.send(this)'>Сохранить</div>"
	columns = {all: table.columns, text: [], inline: []}
	for c in columns.all
		if c.name is "#{model}_id"
			ret += "<div class='row'>
				<b>Принадлежит записи</b>
				<div class='treebox' id='treebox_#{c.name}'>"
			treeboxFill = (name) ->
				records = table.records
				if records.length
					ret = "<p onclick='treebox.toggle(this)'><span>Корневая запись</span><i class='icon-arrow-down2'></i></p>"
					roots = []
					for rec in records
						roots.push rec if rec.record["#{name}_id"] is null
					ret += "<ul>"
					for rec in roots
						ret += "<li>"
						if rec.children > 0
							ret += "<div><i class='icon-arrow-down2' onclick='record.treebox(this, \"#{name}\")'></i><p onclick='treebox.pick(this)' data-val='#{rec.record.id}'>#{rec.record.name}</p></div><ul></ul>"
						else
							ret += "<div><p onclick='treebox.pick(this)' data-val='#{rec.record.id}'>#{rec.record.name}</p></div>"
						ret += "</li>"
					ret += "</ul>"
				else
					ret = "<p><span>Корневая запись</span></p>"
				ret + "<input type='hidden' data-type='integer' name='record[#{name}_id]'>"
			record.root model, (name) ->
				$("#treebox_#{name}_id").html treeboxFill name
			, (name) ->
				ret += treeboxFill name
			# records = table.records
			# if records.length
				# ret += "<p onclick='treebox.toggle(this)'><span>Корневая запись</span><i class='icon-arrow-down2'></i></p>"
				# roots = []
				# for record in all
				# 	roots.push record if record[c.name] is null
				# tree = (records) ->
				# 	ret += '<ul>'
				# 	for record in records
				# 		ret += '<li>'
				# 		children = $.grep all, (a) ->
				# 			a[c.name] is record.id
				# 		if children.length
				# 			ret += "<div><i class='icon-arrow-down2' onclick='treebox.toggle(this)'></i><p onclick='treebox.pick(this)' data-id='#{record.id}'>#{record.name}</p></div>"
				# 			tree children
				# 		else
				# 			ret += "<div><p onclick='treebox.pick(this)' data-id='#{record.id}'>#{record.name}</p></div>"
				# 		ret += '</li>'
				# 	ret += '</ul>'
				# tree roots
			# else
			# 	ret += "<p><span>Корневая запись</span></p>"
			ret += "</div>
				</div>"
		else if c.name is 'image'
			image = true
		else if c.type is 'text'
			columns.text.push c
		else if c.name !in ['id', 'position']
			columns.inline.push c
	for c in columns.inline
		name = switch c.name
			when 'name'
				'Название'
			when 'scode'
				'Код'
			when 'price'
				'Цена'
			else
				c.name
		ret += "<label class='row'><p>#{name[0].toUpperCase()+name[1..-1]}: </p><input type='text' data-type='#{c.type}' name='record[#{c.name}]'></label>"
	if image
		ret += "<div class='images-controls'>
				<div class='btn square deepblue' onclick='image.add(this, \"one\")'>Добавить изображение</div>
				<div class='btn red square hidden' onclick='image.removeOne(this)'>Удалить</div>
				<div class='btn red square hidden' onclick='image.removeOne(this, true)'>Удалить с сервера</div>
			</div>
		<div class='input-images one empty'></div>"
	for has_many in table.has_many
		if has_many is 'images'
			ret += "<div class='images-controls'>
				<div class='btn square deepblue' onclick='image.add(this, \"many\")'>Добавить изображения</div>
				<div class='btn red square hidden' onclick='image.chooseToDel(this)'>Удалить</div>
				<div class='btn red square hidden' onclick='image.chooseToDel(this, true)'>Удалить с сервера</div>
			</div>
			<div class='input-images many empty'></div>"
	for text in columns.text
		name = switch text.name
			when 'description'
				'Описание'
			when 'shortdesc'
				'Короткое описание'
			else
				text.name
		ret += "<h2 class='textarea'>#{name}</h2><textarea rows='25' name='record[#{text.name}]'></textarea>"
	ret += "<div class='btn green dashed' onclick='tinyMCE.triggerSave(); record.send(this)'>Сохранить</div>
		</form>
	</div>
	<script src='/tinyMCE/tinymce.min.js'>"
	ret

app.after = ->
	tinymce.init selector: "textarea", plugins: 'link image code textcolor', language : 'ru'