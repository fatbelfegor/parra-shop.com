app.routes['model/:model/new'].page = app.routes['model/:model/edit/:id'].page = ->
	$(window).off 'scroll'
	name = param.model
	template = app.templates.form[name]
	param.id = parseInt param.id
	id = param.id
	window[k] = v for k, v of template.functions if template.functions
	cb = ->
		id = parseInt param.id
		if id
			window.rec = db[param.model].records[id]
		else window.rec = false
		window.model = param.model
		app.yield.html template.page() + "<link rel='stylesheet' type='text/css' href='/lightbox/lightbox.min.css'><script src='/tinyMCE/tinymce.min.js'><script src='/lightbox/lightbox.min.js'>"
		addFormCb()
		app.menu.find(".current").removeClass 'current'
		app.menu.find("[data-route='model/#{param.model}']").addClass 'current'
	window.form = (html, rel) ->
		"<form class='content form'#{unless rel then " id='main-form'" else ''} data-model='#{window.model}'>#{if window.rec then "<input type='hidden' name='id' value='#{window.rec.id}'>" else ''}#{html}</form>"
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
	window.title = (name) -> "<div class='header'>
			<div class='top'>
				<div>
					<div class='name capitalize'>#{name}</div>
					<div><div onclick='save()' class='btn green'>#{if window.rec then 'Сохранить' else 'Добавить'}</div></div>
				</div>
			</div>
		</div>"
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
	window.images = (header) ->
		ret = "<div class='images-form' #{if window.rec then " data-record-id='#{window.rec.id}'" else ''}>"
		if window.rec
			images = db.images window.model.classify(), window.rec.id
			for img in images
				ret += "<div class='image' data-id='#{img.id}'>
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
		model = form.data 'model'
		app.templates.form[model].beforeSave() if app.templates.form[model].beforeSave
		form.find("[data-validate]").each -> validate @
		return if $('.validation.active').length
		fd = new FormData()
		d = {}
		d[model] = rec: [{fields: {}}]
		fd_path = "model[#{model}]rec[0]"
		form.find('input, textarea').each ->
			unless $(@).data 'ignore'
				return if $(@).parents('.relation').length
				ret = fillData @, fd_path, model, fd
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
									ret = fillData @, next_path, rel_model, fd
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
		db.save d, fd, (res) ->
			for k, v of res
				if v[0].id
					app.go "/admin/model/#{k}/edit/#{v[0].id}", cb: -> notify 'Запись создана'
				else
					setIdsInRelations = (obj) ->
						for model, records of obj
							html_records = $(".relation-window[data-model='#{model}'] > .relation-record").get()
							for i, record of records
								if record.id
									$(html_records[i]).data 'id', record.id
								if record.model
									setIdsInRelations record.model
					for k, v of res
						if v[0].model
							setIdsInRelations v[0].model
					notify "Запись сохранена"
				break
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
		db.collect window.data
		cb()
	else
		get = []
		if param.id
			rec = model: param.model, find: param.id
			if template.belongs_to
				window.rec.belongs_to = []
				window.rec.belongs_to.push bt for bt in template.belongs_to
			rec.has_many = template.has_many if template.has_many
			rec.ids = template.ids if template.ids
			get.push rec
		get.push p for p in template.get if template.get
		if get.length
			db.get get, cb
		else cb()