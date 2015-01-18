app.page = ->
	model = app.data.route.model
	table = tables[model]
	id = app.data.route.id
	if id
		unless rec = record.find table.records, id
			rec = app.data.record
			delete app.data.record
			if 'images' in table.has_many
				images = app.data.images
				delete app.data.images
				tables['image'].records = images
			table.records.push rec
	c_or_u = (c, u) ->
		if id
			u || ''
		else
			c
	ret = "<a onclick='app.aclick(this)' id='backButton'><i class='icon-arrow-left5'></i><span></span></a>
	<h1 class='title'>#{c_or_u 'Добавить запись', 'Редактировать запись'} <b>#{word model}</b></h1>
	<div class='content'>
		<form data-table='#{table.singularize}' action='model/#{table.singularize}/#{c_or_u "create", "update/#{id}"}'>
			<div class='btn green dashed' onclick='tinyMCE.triggerSave(); record.#{c_or_u 'create', 'update'}(this)'>#{c_or_u 'Создать', 'Сохранить'}</div>"
	template = settings.template.form.model[model]
	if template
		for c in template.headers
			ret += "<label class='big'><div>#{word c.name}</div><input type='text'#{record.val rec, c}#{if c.validate then " data-validate=#{JSON.stringify c.validate}" else ''} data-type='#{c.type}' name='record[#{c.name}]'><p class='error'></p></label><br>"
		for r in template.rows
			ret += "<div class='row'#{if r.margin then " style='margin-bottom: #{r.margin}px'" else ''}>"
			width = " style='width: #{100 / r.cols.length}%'"
			for c in r.cols
				if c
					switch c.type
						when 'belongs_to'
							ret += treebox.belongs_to c, width, rec
						when 'h2'
							ret += "<h2#{width} class='noborder'>#{word c.name}</h2>"
						when 'b'
							ret += "<b#{width} class='noborder'>#{word c.name}</b>"
						when 'table'
							ret += "<div class='noborder'><table>"
							for tr in c.rows
								ret += "<tr#{if tr.id then " id='#{tr.id}'" else ''}>"
								for tc in tr.cols
									switch tc.type
										when 'th'
											ret += "<th>#{tc.name}</th>"
								ret += "</tr>"
							ret += "</table></div>"
						when 'custom'
							ret += "<div class='noborder'#{width}>#{c.name}</div>"
						else
							ret += "<div#{width} class='noborder'><label class='col'><p class='capitalize'>#{word c.name}: </p><div class='text'><input type='text' data-type='#{c.type}'#{if c.validate then " data-validate=[#{c.validate.join ','}]" else ''}#{record.val rec, c} name='record[#{c.name}]'></div><p class='error'></p></label></div>"
				else
					ret += "<div class='noborder'#{width}></div>"
			ret += "</div>"
	else
		columns = {all: table.columns, belongs_to: [], text: [], inline: [], text_inline: []}
		for c in columns.all
			if c.name is 'name'
				dataValidate = []
				dataValidate.push "'presence'" if !c.null
				ret += "<label class='big'><div>Название</div><input type='text'#{record.val rec, c} data-validate=[#{dataValidate.join ','}] data-type='#{c.type}' name='record[#{c.name}]'><p class='error'></p></label><br>"
			else if c.name[-3..-1] is "_id"
				columns.belongs_to.push c
			else if c.name is 'image'
				image = true
			else if c.name is 'seo_description'
				columns.text_inline.push c
			else if c.type is 'text'
				columns.text.push c
			else if c.name !in ['id', 'position', 'created_at', 'updated_at']
				columns.inline.push c
		for c in columns.belongs_to
			ret += treebox.belongs_to c, width, rec
		for c in columns.inline
			name = switch c.name
				when 'scode'
					'Код'
				when 'price'
					'Цена'
				else
					c.name
			dataValidate = []
			dataValidate.push "'presence'" if !c.null
			ret += "<label class='row'><p>#{name[0].toUpperCase()+name[1..-1]}: </p><input type='text' data-type='#{c.type}' data-validate=[#{dataValidate.join ','}]#{record.val rec, c} name='record[#{c.name}]'><p class='error'></p></label>"
		for c in columns.text_inline
			name = c.name
			ret += "<label class='row textarea'><p>#{name[0].toUpperCase()+name[1..-1]}: </p><textarea data-type='#{c.type}' name='record[#{c.name}]'>#{record.col rec, c}</textarea></label>"
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
			ret += "<h2 class='textarea'>#{name}</h2><textarea class='tinyMCE' rows='25' name='record[#{text.name}]'>#{record.col rec, text}</textarea>"
	ret += "<div class='btn green dashed' onclick='tinyMCE.triggerSave(); record.#{c_or_u 'create', 'update'}(this)'>#{c_or_u 'Создать', 'Сохранить'}</div>
		</form>
	</div>"
	ret + "<script src='/tinyMCE/tinymce.min.js'>"
app.after = ->
	name = app.data.route.model
	template = settings.template.form.model[name] or settings.template.form.common
	template.cb() if template and template.cb
	tinymce.init selector: ".tinyMCE", plugins: 'link image code textcolor', language : 'ru'