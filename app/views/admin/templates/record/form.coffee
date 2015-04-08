app.preload = ->
	name = param.model
	template = app.templates.form[name]
	ret = []
	if template
		id = parseInt param.id
		if id
			rec = model: name, find: id
			rec.belongs_to = template.belongs_to if template.belongs_to
			rec.has_many = template.has_many if template.has_many
			rec.ids = template.ids if template.ids
			if template.with_id
				for with_id in template.with_id
					with_id.id id
					ret.push with_id.param
			ret.push rec
		ret.push p for p in template.preload if template.preload
	if ret.length
		ret
	else null
app.page = ->
	template = app.templates.form[param.model]
	if template
		id = parseInt param.id
		name = param.model
		model = models[name]
		rec = model.find id if id
		images = models.image.where imageable_type: model.name, imageable_id: id if 'images' in model.has_many
		action = if id then 'update' else 'create'
		window.vars = template.vars if template.vars
		window.functions[k] = v for k, v of template.functions if template.functions
		"<a onclick='app.aclick(this)' id='backButton'><i class='icon-arrow-left5'></i><span></span></a>
		<h1 class='title'>#{if id then 'Редактировать запись' else 'Добавить запись'} <b>#{name}</b></h1>
		<form class='content form' data-action='#{if id then 'update' else 'new'}'><div class='btn green m15' onclick='functions.save(this)'>#{if id then 'Сохранить' else 'Создать'}</div>#{functions.tableGen template.table, rec, undefined, param.id, param.model}<br><div class='btn green m15' onclick='functions.save(this)'>#{if id then 'Сохранить' else 'Создать'}</div></form><link rel='stylesheet' type='text/css' href='/lightbox/lightbox.min.css'><script src='/tinyMCE/tinymce.min.js'><script src='/lightbox/lightbox.min.js'>"
	else
		"<h2>Отсутствует шаблон формы.</h2><br><a class='btn blue' onclick='app.aclick(this)' href='/admin/model/#{param.model}/templates/form'>Создать</a>"
app.functions =
	addRelation: (el) ->
		wrap = $(el).next()
		rel = @find_relation app.templates.form[param.model].relations, parseInt wrap.data 'relationId'
		template = app.templates.form[rel.model]
		wrap.prepend "<div class='relation-record-wrap' data-action='new' data-record-index='#{wrap.find('> div[data-action=\"new\"]').length}'><div class='btn red removeRecord' onclick='functions.removeRecord(this)'><i class='icon-remove4'></i>Удалить запись</div>#{@tableGen template.table, undefined, rel.without_tr, undefined, rel.model}</div>"
		@addFormCb()
	removeRecord: (el) ->
		wrap = $(el).parent().attr 'id', 'removeRecord'
		ask "Удалить запись?",
			ok:
				html: "Удалить"
				class: "red"
			action: ->
				wrap = $('#removeRecord').attr 'id', ''
				data = wrap.data()
				if data.action is 'new'
					index = data.recordIndex
					prev = wrap.prev()
					while prev.length
						prev.data 'recordIndex', index
						index += 1
						prev = prev.prev()
					wrap.remove()
				else
					model = data.model
					id = data.recordId
					$.ajax
						url: "/admin/model/#{model}/destroy/#{id}"
						type: 'POST'
						contentType: false
						processData: false
						dataType: "json"
						success: (res) ->
							if res is 'permission denied'
								notify 'Доступ запрещен', class: 'red'
							else
								delete models[model].collection[id]
								index = data.recordIndex
								next = wrap.next()
								while next.length and next.data('action') is 'update'
									next.data 'recordIndex', index
									index -= 1
									next = next.next()
								wrap.remove()
								notify "Запись удалена"
			cancel: -> $('#removeRecord').attr 'id', ''
	find_relation: (relations, id) ->
		ret = false
		for r in relations
			if r.relation_id is id
				ret = r
				break
			if r.relations
				ret = @find_relation r.relations, id
				break if ret
		ret
	trGen: (table, tr, rec, id, model) ->
		ret = ""
		if tr.set
			tr.set rec
		ret += "<tr>"
		for td in tr.td
			td.set rec if td.set
			continue if td.only and td.only isnt action
			if id and td.belongs_to
				rec = rec[td.belongs_to]()
			if td.th
				tag = 'th'
			else tag = 'td'
			ret += "<#{tag}"
			if td.attrs
				for k, v of td.attrs
					ret += " #{k}='#{v}'"
			ret += ">"
			if td.treebox
				tb = td.treebox
				tb.style = 'width: 100%'
				tb.input = name: "#{td.field}"
				if id
					tb.rec = rec
				else if app.qparam[td.field]
					bt_rec = models[td.field[0..-4]].find app.qparam[td.field]
					tb.rec = bt_rec if bt_rec
				if id
					tb.notModel = param.model
					tb.notId = id
				ret += "<div class='row'><p>#{td.header}</p>#{treebox.gen tb}</div>"
			else if td.field
				val = if id then rec[td.field] else ''
				val = td.val_cb val if td.val_cb
				ret += "<label class='row'"
				ret += " style='position: relative'" if td.validation
				ret += ">"
				ret += "<p>#{td.header}</p>" if td.header
				ret += "<input type='#{td.type || 'text'}' name='#{td.field}'"
				if td.format
					ret += " data-format='#{JSON.stringify td.format}'"
					if val
						if id and td.format.decimal
							if td.format.decimal is "currency"
								val = val.toCurrency() + ' руб.'
						else if td.format.date
							val = new Date(val).toString td.format.date
				ret += " value='#{val}'" if val?
				onchanges = []
				if td.fieldAttrs
					for k, v of td.fieldAttrs
						if k is 'onchange'
							onchanges.push v
						else ret += " #{k}='#{v}'"
				if td.validation
					onchanges.push "validate(this)"
					ret += " data-validate-was='#{if id then rec[td.field] else ''}'"
					ret += " data-validate='#{JSON.stringify td.validation}'"
				ret += " onchange='#{onchanges.join ';'}'" if onchanges.length
				ret += ">"
				if td.validation
					ret += "<div class='validation'><p></p></div>"
				ret += "</label>"
			else if td.show
				ret += rec[td.show]
			else if td.checkbox
				if id and rec[td.checkbox]
					checked = true
				else checked = false
				ret += "<div class='row'>
					<label class='checkbox'>
						<div#{if checked then " class='checked'" else ''}>
							<input#{if checked then " checked" else ''} type='checkbox' name='#{td.checkbox}' onchange='$(this).parent().toggleClass(\"checked\")'>
						</div>#{if td.header then td.header else ''}
					</label>
				</div>"
			else if td.html
				ret += td.html
			else if td.text
				text = {}
				ret += "<div class='nav-tabs'>"
				active = true
				for n of td.text
					ret += "<p onclick='openTab(this)' class='#{if active then active = false; 'active ' else ''}capitalize'>#{n}</p>"
				ret += "</div><div class='tabs'>"
				active = true
				for n, f of td.text
					if f.type is 'editor'
						ret += "<div data-field='#{f.field}' #{if active then active = false; " class='active'" else ''}><textarea class='tinyMCE' rows='25' name='#{f.field}' value='#{if id then rec[f.field] else ''}'></textarea></div>"
					else if f.type is 'textarea'
						ret += "<div class='textarea-wrap#{if active then active = false; " active" else ''}'><textarea name='#{f.field}'>#{if id then rec[f.field] || '' else ''}</textarea></div>"
				ret += "</div>"
			else if td.image
				ret += "<div class='image-form'>"
				if id and rec[td.image]
					url = rec[td.image]
					ret += "<div>
						<div class='btn red remove' onclick='image.removeOneImage(this, \"#{td.image}\", \"#{url}\")'></div>
						<a href='#{url}' data-lightbox='product'><img src='#{url}'></a>
					</div>"
					hide = true
				ret += "</div><label class='text-center#{if hide then ' hide' else ''}'><div class='btn blue ib'>#{if td.header then td.header else "Добавить изображение"}</div><input class='hide image-file' onchange='window.image.upload(this)' name='#{td.image}' type='file'></label>"
			else if td.images
				ret += "<div class='images-form' #{if id then " data-record-id='#{rec.id}' data-model='#{rec.modelName}'" else ''}>"
				if id
					images = rec.images()
					for img in images
						ret += "<div data-id='#{img.id}'>
							<div class='btn red remove' onclick='window.image.removeImage(this)'></div>
							<a href='#{img.url}' data-lightbox='product'><img src='#{img.url}'></a>
						</div>"
				ret += "</div>
					<div class='images-container'>
						<label class='text-center'><div class='btn blue ib'>#{if td.header then td.header else "Добавить изображение"}</div><input class='hide images-file' onchange='window.image.upload(this)' type='file' name='images' multiple></label>
					</div>"
			else if td.relation_id
				rel = @find_relation app.templates.form[param.model].relations, td.relation_id
				ret += "<div class='panel gray'>
						<p>#{rel.header}</p>
						<div>
							<div class='btn blue ib always' onclick='functions.addRelation(this)'>#{rel.addBtn}</div>
							<div class='form-relation-wrap' data-relation-id='#{td.relation_id}'>"
				if id
					template = app.templates.form[rel.model]
					for r, i in rec[models[rel.model].pluralize]()
						ret += "<div class='relation-record-wrap' data-action='update' data-record-index='#{i}' data-model='#{rel.model}' data-record-id='#{r.id}'><div class='btn red removeRecord' onclick='functions.removeRecord(this)'><i class='icon-remove4'></i>Удалить запись</div>#{@tableGen template.table, r, rel.without_tr, r.id, rel.model}</div>"
				ret += "</div>
						</div>
					</div>"
			else if td.habtm_checkboxes
				ids = rec[td.habtm_checkboxes.model + '_ids'] if id
				ret += "<div class='panel'>
					<p>#{td.header}</p>
					<div>
						<table class='checkboxes'>"
				recs = []
				for k, v of models[td.habtm_checkboxes.model].collection
					recs.push v
				while recs.length
					row = recs.splice 0, td.row
					ret += "<tr>"
					for td_rec in row
						if id and td_rec.id in ids
							checked = true
						else checked = false
						ret += "<td>
							<div class='row'>
								<label class='checkbox'>
									<div#{if checked then " class='checked'" else ''}>
										<input#{if checked then " checked" else ''} class='habtm_checkboxes' type='checkbox' name='#{td.habtm_checkboxes.model + '_ids'}' value='#{td_rec.id}' onchange='$(this).parent().toggleClass(\"checked\")'>
									</div>#{td_rec[td.habtm_checkboxes.header]}
								</label>
							</div>
						</td>"
					ret += "</tr>"
				ret += "</table>
					</div>
				</div>"
			ret += "</#{tag}>"
		ret += "</tr>"
		ret
	tableGen: (tabls, rec, without_tr, id, model) ->
		ret = ""
		for t in tabls
			t.before() if t.before
			ret += "<table"
			if t.attrs
				for k, v of t.attrs
					ret += " #{k}='#{v}'"
			ret += ">"
			for tr in t.tr
				if without_tr
					continue if tr.without_tr and without_tr in tr.without_tr
				ret += @trGen t, tr, rec, undefined, id, model
			ret += "</table>"
		ret
	save: (el) ->
		unless $('.validation.active').length
			template = app.templates.form[param.model]
			template.beforeSave() if template.beforeSave
			form = $(el).parent()
			data = {relation: [{model: param.model}]}
			main_action = form.data 'action'
			data.relation[0][main_action + '_records'] = [fields: {}]
			formData = new FormData()
			formData.append "relation[0]model", param.model
			if main_action is 'update'
				data.relation[0][main_action + '_records'][0].id = param.id
				formData.append "relation[0]#{main_action}_records[0]id", param.id
			model = models[param.model]
			relations = template.relations
			data.relations = relations
			if relations
				relationsParam = (formData, relations, rel_id) ->
					for rel in relations
						formData.append "relations[#{rel_id}][]", rel.relation_id
						relationsParam formData, rel.relations, rel.relation_id if rel.relations
				relationsParam formData, relations, 0
			form.find('input').each ->
				el = $ @
				wrap = el.parents('.form-relation-wrap').eq(0)
				if wrap.length
					relation_id = wrap.data 'relationId'
					relation_model = functions.find_relation(relations, relation_id).model
					rel_data = el.parents('.relation-record-wrap').eq(0).data()
					index = rel_data.recordIndex
					action = rel_data.action
				else
					relation_id = 0
					index = 0
					action = main_action
				unless data.relation[relation_id]
					data.relation[relation_id] = model: relation_model
					formData.append "relation[#{relation_id}]model", relation_model
				data.relation[relation_id][action + '_records'] ?= []
				data.relation[relation_id][action + '_records'][index] ?= fields: {}
				if action is 'update' and !data.relation[relation_id][action + '_records'][index].id
					data.relation[relation_id][action + '_records'][index].id = rel_data.recordId
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]id", rel_data.recordId
				if el.hasClass 'image-file'
					file = @.files[0]
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]image[#{@.name}]", file if file
				else if el.hasClass 'images-file'
					if @.files.length
						label = el.parent()
						label_index = label.index() + 1
						removeNew = label.parent().data 'removeNew'
						for image, i in @.files
							if !removeNew or "#{label_index}-#{i}" not in removeNew
								formData.append "relation[#{relation_id}]#{action}_records[#{index}]images[]", image
				else if @.name is 'removeImage'
					data.relation[relation_id][action + '_records'][index].removeImage ?= []
					field = el.data 'field'
					data.relation[relation_id][action + '_records'][index].removeImage.push field
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]removeImage[]", field
				else if @.name is 'removeImages'
					data.relation[relation_id][action + '_records'][index].removeImages ?= []
					remove_id = el.parent().data 'id'
					data.relation[relation_id][action + '_records'][index].removeImages.push remove_id
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]removeImages[]", remove_id
				else if el.hasClass 'habtm_checkboxes'
					unless data.relation[relation_id][action + '_records'][index].fields[@.name]
						data.relation[relation_id][action + '_records'][index].fields[@.name] = []
						unless el.parents('.checkboxes').eq(0).find('input:checked').length
							formData.append "relation[#{relation_id}]#{action}_records[#{index}]fields[#{@.name}]", []
					if @.checked
						data.relation[relation_id][action + '_records'][index].fields[@.name].push parseInt @.value
						formData.append "relation[#{relation_id}]#{action}_records[#{index}]fields[#{@.name}][]", @.value
				else if @.type is 'checkbox'
					value = @.checked
					data.relation[relation_id][action + '_records'][index].fields[@.name] = value
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]fields[#{@.name}]", value
				else
					value = el.val()
					format = el.data 'format'
					if format
						if format.decimal
							if format.decimal is 'currency'
								value = parseFloat(value.replace(' ', ''))
						else if format.date
							value = Date.parseExact value, format.date
					data.relation[relation_id][action + '_records'][index].fields[@.name] = value
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]fields[#{@.name}]", value
			form.find('textarea').each ->
				el = $ @
				unless el.hasClass 'tinyMCE-ready'
					val = el.val()
					field = @.name
					wrap = el.parents('.form-relation-wrap').eq(0)
					if wrap.length
						relation_id = wrap.data 'relationId'
						relation_model = functions.find_relation(relations, relation_id).model
						rel_data = el.parents('.relation-record-wrap').eq(0).data()
						index = rel_data.recordIndex
						action = rel_data.action
					else
						relation_id = 0
						index = 0
						action = main_action
					unless data.relation[relation_id]
						data.relation[relation_id] = model: relation_model
						formData.append "relation[#{relation_id}]model", relation_model
					data.relation[relation_id][action + '_records'] ?= []
					data.relation[relation_id][action + '_records'][index] ?= fields: {}
					if action is 'update' and !data.relation[relation_id][action + '_records'][index].id
						data.relation[relation_id][action + '_records'][index].id = rel_data.recordId
						formData.append "relation[#{relation_id}]#{action}_records[#{index}]id", rel_data.recordId
					data.relation[relation_id][action + '_records'][index].fields[field] = val
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]fields[#{field}]", val
			$('.tinyMCE-ready').each ->
				el = $ @
				description = tinyMCE.get(@.id).getContent()
				field = el.parent().data 'field'
				wrap = el.parents('.form-relation-wrap').eq(0)
				if wrap.length
					relation_id = wrap.data 'relationId'
					relation_model = functions.find_relation(relations, relation_id).model
					rel_data = el.parents('.relation-record-wrap').eq(0).data()
					index = rel_data.recordIndex
					action = rel_data.action
				else
					relation_id = 0
					index = 0
					action = main_action
				unless data.relation[relation_id]
					data.relation[relation_id] = model: relation_model
					formData.append "relation[#{relation_id}]model", relation_model
				data.relation[relation_id][action + '_records'] ?= []
				data.relation[relation_id][action + '_records'][index] ?= fields: {}
				if action is 'update' and !data.relation[relation_id][action + '_records'][index].id
					data.relation[relation_id][action + '_records'][index].id = rel_data.recordId
					formData.append "relation[#{relation_id}]#{action}_records[#{index}]id", rel_data.recordId
				data.relation[relation_id][action + '_records'][index].fields[field] = description
				formData.append "relation[#{relation_id}]#{action}_records[#{index}]fields[#{field}]", description
			record.save data, formData: formData
	addFormCb: ->
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
app.after = ->
	functions.addFormCb()
	parent = app.menu.find("[data-route='model/#{param.model}']").addClass('current open').parents('li').eq(0)
	while parent.length
		parent.addClass 'active open'
		parent = parent.parents('li').eq(0)