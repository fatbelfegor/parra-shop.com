app.routes['model/:model/new'].page = app.routes['model/:model/edit/:id'].page = ->
	name = param.model
	template = app.templates.form[name]
	param.id = parseInt param.id
	id = param.id
	window[k] = v for k, v of template.functions if template.functions
	cb = ->
		id = parseInt param.id
		if id
			window.rec = db[param.model].records[id]
			action = 'update'
		else
			window.rec = false
			action = 'create'
		window.model = param.model
		app.yield.html template.page() + "<link rel='stylesheet' type='text/css' href='/lightbox/lightbox.min.css'><script src='/tinyMCE/tinymce.min.js'><script src='/lightbox/lightbox.min.js'>"
		addFormCb()
		app.menu.find(".current").removeClass 'current'
		app.menu.find(".active").removeClass 'active'
		parent = app.menu.find("[data-route='model/#{param.model}']").addClass('current open').parents('li').eq(0)
		while parent.length
			parent.addClass 'active open'
			parent = parent.parents('li').eq(0)
	window.form = (html, rel) ->
		"<form class='content form'#{unless rel then " id='main-form'" else ''} data-model='#{window.model}' data-action='#{if id then 'update' else 'new'}'>#{if window.rec then "<input type='hidden' name='id' value='#{window.rec.id}'>" else ''}#{html}</form>"
	window.relation = (name, visible, html, params) ->
		params ?= {}
		params.attrs ?= {}
		unless visible
			if params.attrs.style
				params.attrs.style += '; display: none'
			else params.attrs.style = 'display: none'
		ret = "<div class='relation relation-window mt10'"
		for k, v of params.attrs
			ret += " #{k}='#{v}'"
		ret + " data-model='#{name}'>#{html}</div>"
	window.relation_add = (val, onclick) ->
		"<div class='text-center'><div class='ib btn blue' onclick='#{onclick}($(this).parent().next().show())'>#{val}</div></div>"
	window.relation_record = (html) ->
		"<div#{if window.rec then " data-id='#{window.rec.id}'" else ''} class='relation-record'><div class='btn red remove-relation' onclick='$(this).parent().remove()'>Удалить</div>#{html}</div>"
	window.btn_save = -> "<div class='btn green m15' onclick='save()'>#{if window.rec then 'Сохранить' else 'Создать'}</div>"
	window.title = (name) -> "<h1 class='title'>#{if window.rec then 'Редактировать ' else 'Добавить '} <b>#{name}</b></h1>"
	window.tr = (html, params) ->
		ret = "<tr"
		ret += " #{k}='#{v}'" for k, v of params.attrs if params and params.attrs
		ret + ">#{if typeof html is 'string' then html else html.join ''}</tr>"
	window.cells = (array) ->
		array.map((a) -> "<tr>#{if typeof a is 'string' then a else a.join ''}</tr>").join ''
	window.td = (html, params) ->
		ret = "<td"
		ret += " #{k}='#{v}'" for k, v of params.attrs if params and params.attrs
		ret + ">#{html}</td>"
	window.tb = (header, model, tb) ->
		tb.style = 'width: 100%'
		tb.input = name: model + "_id"
		if window.rec
			tb.rec = db.find_one model, window.rec[model + '_id']
			tb.notModel = param.model
			tb.notId = window.rec.id
		else if app.qparam[model + '_id']
			bt_rec = db[model].records[app.qparam[model + '_id']]
			tb.rec = bt_rec if bt_rec
		"<div class='row'><p>#{header}</p>" + treebox.gen(tb) + "</div>" 
	window.habtm_checkboxes = (header, model, name, col) ->
		ids = window.rec[model + '_ids'] if window.rec
		ret = "<div class='panel'><p>#{header}</p><div><table class='checkboxes'>"
		recs = []
		for k, v of db[model].records
			recs.push v
		while recs.length
			row = recs.splice 0, col
			ret += "<tr>"
			for td_rec in row
				if id and td_rec.id in ids
					checked = true
				else checked = false
				ret += "<td>
					<div class='row'>
						<label class='checkbox'>
							<div#{if checked then " class='checked'" else ''}>
								<input#{if checked then " checked" else ''} class='habtm_checkboxes' type='checkbox' name='#{model + '_ids'}' value='#{td_rec.id}' onchange='$(this).parent().toggleClass(\"checked\")'>
							</div>#{td_rec[name]}
						</label>
					</div>
				</td>"
			ret += "</tr>"
		ret + "</table></div></div>"
	window.field = (header, name, params) ->
		params ?= {}
		val = if window.rec then window.rec[name] else ''
		val = params.val_cb val if params.val_cb
		ret = "<label class='row'#{if params.validation then " style='position: relative'" else ''}>"
		ret += "<p>#{header}</p>" if header
		ret += "<input type='#{params.type || 'text'}' name='#{name}'"
		if params.format
			ret += " data-format='#{JSON.stringify params.format}'"
			if val
				if window.rec and params.format.decimal
					if params.format.decimal is "currency"
						val = val.toCurrency() + ' руб.'
				else if params.format.date
					val = new Date(val).toString params.format.date
			else if (params.format.not_null or params.format.decimal or params.format.date) and val is null
				val = ''
		ret += " value='#{val}'"
		onchanges = []
		if params.attrs
			for k, v of params.attrs
				if k is 'onchange'
					onchanges.push v
				else ret += " #{k}='#{v}'"
		if params.validation
			onchanges.push "validate(this)"
			ret += " data-validate-was='#{if window.rec then window.rec[name] else ''}'
				data-validate='#{JSON.stringify params.validation}'"
		ret += "#{if onchanges.length then " onchange='#{onchanges.join ';'}'" else ''}>"
		ret += "<div class='validation'><p></p></div>" if params.validation
		ret + "</label>"
	window.checkbox = (header, name) ->
		"<div class='row'>
			<label class='checkbox'>
				<div#{if window.rec[name] then " class='checked'" else ''}>
					<input#{if window.rec[name] then " checked" else ''} type='checkbox' name='#{name}' onchange='$(this).parent().toggleClass(\"checked\")'>
				</div>#{header or ''}
			</label>
		</div>"
	window.radio_input = (name, header, value, params) ->
		params ?= {}
		attrs = ""
		attrs += " #{k}='#{v}'" for k, v of params.attrs if params.attrs
		"<div class='row'>
			<label class='radio'>
				<div#{if params.checked then " class='checked'" else ''}>
					<input#{if params.checked then " checked" else ''}#{attrs} type='radio' value='#{value}' name='#{name}' onclick='window.el = this;radio(this)'>
				</div>#{header}
			</label>
		</div>"
	window.image_field = (header, name, params) ->
		ret = "<div class='image-form'>"
		if window.rec and window.rec[name]
			url = window.rec[name]
			ret += "<div>
				<div class='btn red remove' onclick='image.removeOneImage(this, \"#{name}\", \"#{url}\")'></div>
				<a href='#{url}' data-lightbox='product'><img src='#{url}'></a>
			</div>"
			hide = true
		td ret + "</div><label class='text-center#{if hide then ' hide' else ''}'><div class='btn blue ib'>#{header}</div><input class='hide image-file' onchange='window.image.upload(this)' name='#{name}' type='file'></label>", params
	window.images = (header) ->
		ret = "<div class='images-form' #{if window.rec then " data-record-id='#{window.rec.id}'" else ''}>"
		if window.rec
			images = db.images window.model.classify(), window.rec.id
			for img in images
				ret += "<div data-id='#{img.id}'>
					<div class='btn red remove' onclick='window.image.removeImage(this)'></div>
					<a href='#{img.url}' data-lightbox='product'><img src='#{img.url}'></a>
				</div>"
		ret + "</div>
			<div class='images-container'>
				<label class='text-center'><div class='btn blue ib'>#{if header then header else "Добавить изображение"}</div><input class='hide images-file' onchange='window.image.upload(this)' type='file' name='images' multiple></label>
			</div>"
	window.text = (texts) ->
		ret = "<div class='nav-tabs'>"
		active = true
		for n of texts
			ret += "<p onclick='openTab(this)' class='#{if active then active = false; 'active ' else ''}capitalize'>#{n}</p>"
		ret += "</div><div class='tabs'>"
		active = true
		for n, f of texts
			if typeof f is 'string'
				ret += "<div data-field='#{f}' #{if active then active = false; " class='active'" else ''}><textarea class='tinyMCE' rows='25' name='#{f}' value='#{if window.rec then window.rec[f] else ''}'></textarea></div>"
			else
				for n, t of f
					ret += "<div class='textarea-wrap#{if active then active = false; " active" else ''}'><textarea name='#{n}'>#{if window.rec then window.rec[n] || '' else ''}</textarea></div>"
		ret + "</div>"
	window.save = ->
		form = $ '#main-form'
		action = form.data 'action'
		model = form.data 'model'
		app.templates.form[model].beforeSave() if app.templates.form[model].beforeSave
		form.find("[data-validate]").each -> validate @
		return if $('.validation.active').length
		fd = new FormData()
		d = {}
		d[model] = rec: [{fields: {}}]
		fillData = (el, prefix, model) ->
			data = fields: {}
			$el = $ el
			if $el.hasClass 'image-file'
				file = el.files[0]
				fd.append "#{prefix}image[#{el.name}]", file if file
			else if $el.hasClass 'images-file'
				if el.files.length
					label = $el.parent()
					label_index = label.index() + 1
					removeNew = label.parent().data 'removeNew'
					for image, i in el.files
						if !removeNew or "#{label_index}-#{i}" not in removeNew
							fd.append "#{prefix}images[]", image
			else if el.name is 'removeImage'
				field = $el.data 'field'
				data.removeImage = field
				fd.append "#{prefix}removeImage[]", field
			else if el.name is 'removeImages'
				remove_id = $el.parent().data 'id'
				data.removeImages = remove_id
				fd.append "#{prefix}removeImage[]", remove_id
			else if $el.hasClass 'habtm_checkboxes'
				unless data.fields[el.name]
					data.fields[el.name] = []
					unless $el.parents('.checkboxes').eq(0).find('input:checked').length
						fd.append "#{prefix}fields[#{el.name}]", []
				if el.checked
					data.fields[el.name].push parseInt el.value
					fd.append "#{prefix}fields[#{el.name}][]", el.value
			else if el.type is 'checkbox'
				value = el.checked
				data.fields[el.name] = value
				fd.append "#{prefix}fields[#{el.name}]", value
			else
				if el.tagName is 'INPUT'
					value = $el.val()
					format = $el.data 'format'
					if format
						if format.decimal
							if format.decimal is 'currency'
								value = parseFloat(value.replace(' ', ''))
						else if format.date and value isnt ''
							value = Date.parseExact value, format.date
				else if $el.hasClass 'tinyMCE-ready'
					value = tinyMCE.get(el.id).getContent()
				else
					value = $el.val()
				data.fields[el.name] = value
				fd.append "#{prefix}fields[#{el.name}]", value
			data
		fd_path = "model[#{model}]rec[0]"
		form.find('input, textarea').each ->
			unless $(@).data 'ignore'
				return if $(@).parents('.relation').length
				ret = fillData @, fd_path, model
				for k, v of ret.fields
					d[model].rec[0].fields[k] = v
				if ret.removeImage
					d[model].rec[0].removeImage ?= []
					d[model].rec[0].removeImage.push ret.removeImage
				if ret.removeImages
					d[model].rec[0].removeImages ?= []
					d[model].rec[0].removeImages.push ret.removeImages
		fillRelations = (wrap, path) ->
			relations = wrap.find('> .relation')
			if relations.length
				rel_data = {}
				relations.each ->
					wrap = $ @
					rel_model = wrap.data 'model'
					rel_data[rel_model] = rec: []
					index = 0
					wrap.find('> .relation-record').each ->
						rel_wrap = $ @
						next_path = "#{path}model[#{rel_model}]rec[#{index}]"
						id = rel_wrap.data 'id'
						rel_data[rel_model].rec[index] = fields: {}
						if id
							rel_data[rel_model].rec[index].fields.id = id
							fd.append "#{next_path}fields[id]", id
						rel_wrap.find('input, textarea').each ->
							unless $(@).data 'ignore'
								if $(@).parents('.relation').first().data('model') is rel_model
									ret = fillData @, next_path, rel_model
									for k, v of ret.fields
										rel_data[rel_model].rec[index].fields[k] = v
									if ret.removeImage
										rel_data[rel_model].rec[index].removeImage ?= []
										rel_data[rel_model].rec[index].removeImage.push ret.removeImage
									if ret.removeImages
										rel_data[rel_model].rec[index].removeImages ?= []
										rel_data[rel_model].rec[index].removeImages.push ret.removeImages
						next_rel_data = fillRelations rel_wrap, next_path
						rel_data[rel_model].rec[index].model = next_rel_data if next_rel_data
						index += 1
				rel_data
			else false
		rel_data = fillRelations form, fd_path
		d[model].rec[0].model = rel_data if rel_data
		db.save d, fd
	window.addFormCb = ->
		if tinymce?
			tinymce.init selector: ".tinyMCE", plugins: 'link image code textcolor', language : 'ru', setup: (editor) ->
				editor.on 'init', (ed) ->
					editor.setContent $(ed.target.editorContainer).next().toggleClass('tinyMCE tinyMCE-ready').attr 'value'
		$(".images-form").sortable
			revert: true
			update: (e, ui) ->
				urls = []
				wrap = $ e.target
				wrap.find('[data-id] a').each -> urls.push $(@).attr 'href'
				if urls.length
					id = wrap.data 'recordId'
					model = wrap.data 'model'
					$.post '/admin/images_sort', urls: urls, id: id, model: model, ->
						for image, i in models[model].find(id).images()
							image.url = urls[i]
					, 'json'
	if window.data
		db.save_many data
		cb()
	else
		get = []
		if id
			rec = model: name, find: id
			rec.belongs_to = template.belongs_to if template.belongs_to
			rec.has_many = template.has_many if template.has_many
			rec.ids = template.ids if template.ids
			get.push rec
		get.push p for p in template.get if template.get
		if get.length
			db.get get, cb
		else cb()