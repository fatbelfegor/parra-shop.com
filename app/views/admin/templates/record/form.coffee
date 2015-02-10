app.page = ->
	name = app.data.route.model
	id = app.data.route.id
	table = tables[name]
	rec = record.find table.records, id if id
	images = record.where 'image', {imageable_type: table.name, imageable_id: id}
	c_or_u = (c, u) ->
		if id
			u || ''
		else
			c
	template = models[name + "_form"]
	ret = "<a onclick='app.aclick(this)' id='backButton'><i class='icon-arrow-left5'></i><span></span></a>
		<h1 class='title'>#{c_or_u 'Добавить запись', 'Редактировать запись'} <b>#{word name}</b></h1>
		<div class='content form'><br>"
	for t in template.table
		ret += "<table>"
		for tr in t.tr
			ret += "<tr>"
			for td in tr.td
				ret += "<td"
				ret += " colspan='#{td.colspan}'" if td.colspan
				ret += ">"
				if td.field
					ret += "<label class='row'>"
					ret += "<p>#{td.header}</p>" if td.header
					ret += "<input type='text' name='record[#{td.field}]'></label>"
				else if td.checkbox
					ret += "<div class='row'><label class='checkbox'><div><input type='checkbox' name='record[#{td.checkbox}]' onchange='$(this).parent().toggleClass(\"checked\")'></div>"
					ret += "#{td.header}" if td.header
					ret += "</label></div>"
				else if td.description
					description = {}
					for n, f of td.description
						description[n] = -> "<textarea class='tinyMCE' rows='25' name='record[#{f}]'></textarea>"
					ret += tab.gen description
				else if td.images
					ret += "<div class='images-form'>"
					for img in images
						ret += "<div>
							<div class='btn red remove'></div>
							<a href='#{img.url}' data-lightbox='product'><img src='#{img.url}'></a>
						</div>"
					ret += "</div><label class='text-center'><div class='btn blue ib'>Добавить изображение</div><input class='hide' onchange='image.upload(this)' type='file' multiple></label>
						<label>"
				ret += "</td>"
			ret += "</tr>"
		ret += "</table>"
	ret + "<br></div><link rel='stylesheet' type='text/css' href='/lightbox/lightbox.min.css'><script src='/tinyMCE/tinymce.min.js'><script src='/lightbox/lightbox.min.js'>"

app.after = ->
	tinymce.init selector: ".tinyMCE", plugins: 'link image code textcolor', language : 'ru'
	$(".images-form").sortable revert: true
# app.page = ->
# 	model = app.data.route.model
# 	table = tables[model]
# 	id = app.data.route.id
	# if id
	# 	unless rec = record.find table.records, id
	# 		rec = app.data.record
	# 		delete app.data.record
	# 		if 'images' in table.has_many
	# 			images = app.data.images
	# 			delete app.data.images
	# 			tables['image'].records = images
	# 		table.records.push rec
# 	c_or_u = (c, u) ->
# 		if id
# 			u || ''
# 		else
# 			c
# 	ret = "<a onclick='app.aclick(this)' id='backButton'><i class='icon-arrow-left5'></i><span></span></a>
# 	<h1 class='title'>#{c_or_u 'Добавить запись', 'Редактировать запись'} <b>#{word model}</b></h1>
# 	<div class='content'>
# 		<form data-table='#{table.singularize}' action='model/#{table.singularize}/#{c_or_u "create", "update/#{id}"}'>
# 			<div class='btn green' onclick='tinyMCE.triggerSave(); record.#{c_or_u 'create', 'update'}(this)'>#{c_or_u 'Создать', 'Сохранить'}</div>"
# 	template = settings.template.form.model[model]
# 	if template
# 		for c in template.headers
# 			ret += "<label class='big'><div>#{word c.name}</div><input type='text'#{record.val rec, c}#{if c.validate then " data-validate=#{JSON.stringify c.validate}" else ''} data-type='#{c.type}' name='record[#{c.name}]'><p class='error'></p></label><br>"
# 		for r in template.rows
# 			ret += "<div class='row'#{if r.margin then " style='margin-bottom: #{r.margin}px'" else ''}>"
# 			width = " style='width: #{100 / r.cols.length}%'"
# 			for c in r.cols
# 				if c
# 					switch c.type
# 						when 'belongs_to'
# 							belongs_to_col = c
# 							belongs_model = c.name[0..-4]
# 							ret += "<div#{width} class='treebox-row'>
# 								<b>#{word tables[belongs_model].name}:</b>
# 								<div class='treebox' id='treebox_#{c.name}'>"
# 							treeboxFill = (name) ->
# 								belongs_table = tables[name]
# 								field = settings.template.form.model[name] or settings.template.form.common
# 								field = field.headers[0].name
# 								records = belongs_table.records
# 								if records.length
# 									ret = "<p onclick='treebox.toggle(this)'><span>"
# 									if rec
# 										bt_id = rec[belongs_to_col.name]
# 										for bt_rec in belongs_table.records
# 											if bt_rec.id is bt_id
# 												ret += bt_rec[field]
# 												break
# 									else
# 										ret += "Выбрать"
# 									ret += "</span><i class='icon-arrow-down2'></i></p>"
# 									ret += "<ul>"
# 									if belongs_table.has_self
# 										roots = []
# 										roots.push bt_rec if bt_rec.record["#{name}_id"] is null for bt_rec in records
# 										for bt_rec in roots
# 											ret += "<li>"
# 											if bt_rec.children > 0
# 												ret += "<div><i class='icon-arrow-down2' onclick='record.treebox(this, \"#{name}\")'></i><p onclick='treebox.pick(this)' data-val='#{rec.id}'>#{rec[field]}</p></div><ul></ul>"
# 											else
# 												ret += "<div><p onclick='treebox.pick(this)' data-val='#{bt_rec.id}'>#{bt_rec[field]}</p></div>"
# 											ret += "</li>"
# 									else
# 										ret += "<li><div><p onclick='treebox.pick(this)' data-val='#{bt_rec.id}'>#{bt_rec[field]}</p></div></li>" for bt_rec in records
# 									ret += "</ul>"
# 								else
# 									ret = "<p><span>Нет записей</span></p>"
# 								ret + "<input type='hidden' data-type='integer' name='record[#{name}_id]'#{record.val rec, belongs_to_col}>"
# 							record.ask {model: belongs_model}, (name) ->
# 								$("#treebox_#{name}_id").html treeboxFill name
# 							, (name) ->
# 								ret += treeboxFill name
# 							ret += "</div></div>"
# 						when 'h2'
# 							ret += "<h2#{width} class='noborder'>#{word c.name}</h2>"
# 						when 'b'
# 							ret += "<b#{width} class='noborder'>#{word c.name}</b>"
# 						when 'table'
# 							ret += "<div class='noborder'><table>"
# 							for tr in c.rows
# 								ret += "<tr#{if tr.id then " id='#{tr.id}'" else ''}>"
# 								for tc in tr.cols
# 									switch tc.type
# 										when 'th'
# 											ret += "<th>#{tc.name}</th>"
# 								ret += "</tr>"
# 							ret += "</table></div>"
# 						when 'custom'
# 							ret += "<div class='noborder'#{width}>#{c.name}</div>"
# 						else
# 							ret += "<div#{width} class='noborder'><label class='col'><p class='capitalize'>#{word c.name}: </p><div class='text'><input type='text' data-type='#{c.type}'#{if c.validate then " data-validate=[#{c.validate.join ','}]" else ''}#{record.val rec, c} name='record[#{c.name}]'></div><p class='error'></p></label></div>"
# 				else
# 					ret += "<div class='noborder'#{width}></div>"
# 			ret += "</div>"
# 	else
# 		columns = {all: table.columns, belongs_to: [], text: [], inline: [], text_inline: []}
# 		for c in columns.all
# 			if c.name is 'name'
# 				dataValidate = []
# 				dataValidate.push "'presence'" if !c.null
# 				ret += "<label class='big'><div>Название</div><input type='text'#{record.val rec, c} data-validate=[#{dataValidate.join ','}] data-type='#{c.type}' name='record[#{c.name}]'><p class='error'></p></label><br>"
# 			else if c.name[-3..-1] is "_id"
# 				columns.belongs_to.push c
# 			else if c.name is 'image'
# 				image = true
# 			else if c.name is 'seo_description'
# 				columns.text_inline.push c
# 			else if c.type is 'text'
# 				columns.text.push c
# 			else if c.name !in ['id', 'position', 'created_at', 'updated_at']
# 				columns.inline.push c
# 		for c in columns.belongs_to
# 			belongs_to_col = c
# 			belongs_model = c.name[0..-4]
# 			ret += "<div class='row'>
# 				<b>#{word tables[belongs_model].name}:</b>
# 				<div class='treebox' id='treebox_#{c.name}'>"
# 			treeboxFill = (name) ->
# 				belongs_table = tables[name]
# 				field = settings.template.form.model[name] or settings.template.form.common
# 				field = field.headers[0].name
# 				records = belongs_table.records
# 				if records.length
# 					ret = "<p onclick='treebox.toggle(this)'><span>"
# 					if rec
# 						bt_id = rec[belongs_to_col.name]
# 						for bt_rec in belongs_table.records
# 							if bt_rec.id is bt_id
# 								ret += bt_rec[field]
# 								break
# 					else
# 						ret += "Выбрать"
# 					ret += "</span><i class='icon-arrow-down2'></i></p>"
# 					ret += "<ul>"
# 					if belongs_table.has_self
# 						roots = []
# 						roots.push bt_rec if bt_rec.record["#{name}_id"] is null for bt_rec in records
# 						for bt_rec in roots
# 							ret += "<li>"
# 							if bt_rec.children > 0
# 								ret += "<div><i class='icon-arrow-down2' onclick='record.treebox(this, \"#{name}\")'></i><p onclick='treebox.pick(this)' data-val='#{rec.id}'>#{rec[field]}</p></div><ul></ul>"
# 							else
# 								ret += "<div><p onclick='treebox.pick(this)' data-val='#{bt_rec.id}'>#{bt_rec[field]}</p></div>"
# 							ret += "</li>"
# 					else
# 						ret += "<li><div><p onclick='treebox.pick(this)' data-val='#{bt_rec.id}'>#{bt_rec[field]}</p></div></li>" for bt_rec in records
# 					ret += "</ul>"
# 				else
# 					ret = "<p><span>Нет записей</span></p>"
# 				ret + "<input type='hidden' data-type='integer' name='record[#{name}_id]'#{record.val rec, belongs_to_col}>"
# 			record.ask {model: belongs_model}, (name) ->
# 				$("#treebox_#{name}_id").html treeboxFill name
# 			, (name) ->
# 				ret += treeboxFill name
# 			ret += "</div></div>"
# 		for c in columns.inline
# 			name = switch c.name
# 				when 'scode'
# 					'Код'
# 				when 'price'
# 					'Цена'
# 				else
# 					c.name
# 			dataValidate = []
# 			dataValidate.push "'presence'" if !c.null
# 			ret += "<label class='row'><p>#{name[0].toUpperCase()+name[1..-1]}: </p><input type='text' data-type='#{c.type}' data-validate=[#{dataValidate.join ','}]#{record.val rec, c} name='record[#{c.name}]'><p class='error'></p></label>"
# 		for c in columns.text_inline
# 			name = c.name
# 			ret += "<label class='row textarea'><p>#{name[0].toUpperCase()+name[1..-1]}: </p><textarea data-type='#{c.type}' name='record[#{c.name}]'>#{record.col rec, c}</textarea></label>"
# 		if image
# 			ret += "<div class='images-controls'>
# 					<div class='btn blue' onclick='image.add(this, \"one\")'>Добавить изображение</div>
# 					<div class='btn red hidden' onclick='image.removeOne(this)'>Удалить</div>
# 					<div class='btn red hidden' onclick='image.removeOne(this, true)'>Удалить с сервера</div>
# 				</div>
# 			<div class='input-images one empty'></div>"
# 		for has_many in table.has_many
# 			if has_many is 'images'
# 				ret += "<div class='images-controls'>
# 					<div class='btn blue' onclick='image.add(this, \"many\")'>Добавить изображения</div>
# 					<div class='btn red hidden' onclick='image.chooseToDel(this)'>Удалить</div>
# 					<div class='btn red hidden' onclick='image.chooseToDel(this, true)'>Удалить с сервера</div>
# 				</div>
# 				<div class='input-images many empty'></div>"
# 		for text in columns.text
# 			name = switch text.name
# 				when 'description'
# 					'Описание'
# 				when 'shortdesc'
# 					'Короткое описание'
# 				else
# 					text.name
# 			ret += "<h2 class='textarea'>#{name}</h2><textarea class='tinyMCE' rows='25' name='record[#{text.name}]'>#{record.col rec, text}</textarea>"
# 	ret += "<div class='btn green' onclick='tinyMCE.triggerSave(); record.#{c_or_u 'create', 'update'}(this)'>#{c_or_u 'Создать', 'Сохранить'}</div>
# 		</form>
# 	</div>"
# 	ret + "<script src='/tinyMCE/tinymce.min.js'>"