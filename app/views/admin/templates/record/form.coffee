app.script = ->
	"models/#{param.model}/form"
app.preload = ->
	id = parseInt param.id
	if id
		name = param.model
		template = app.templates.form[name]
		ret = []
		if id
			rec = model: name, find: id
			rec.belongs_to = template.belongs_to if template.belongs_to
			rec.has_many = template.has_many if template.has_many
			ret.push rec
		ret
	else
		null
app.page = ->
	template = app.templates.form[param.model]
	if template
		id = parseInt param.id
		name = param.model
		model = models[name]
		rec = model.find id if id
		images = models.image.where imageable_type: model.name, imageable_id: id if 'images' in model.has_many
		what = (c, u) ->
			if id then u else c
		action = what 'create', 'update'
		recf = (k) ->
			if id then rec[k] else ''
		trGen = (table, tr, tr_rec, level, collection) ->
			ret = ""
			if collection or !tr.collection
				if tr.set
					tr.set recs: tr_rec, rec: tr_rec[level]
				ret += "<tr>"
				for td in tr.td
					td.set rec: rec, recs: tr_rec if td.set
					continue if td.only and td.only isnt action
					rec = tr_rec[td.level || level]
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
						tb.tag = 'div'
						tb.style = 'width: 100%'
						tb.input = name: "#{td.field}"
						tb.classes = td.class.concat td.class.split(' ') if td.class
						if id
							tb.rec = rec
						else if app.qparam[td.field]
							bt_rec = models[td.field[0..-4]].find app.qparam[td.field]
							tb.rec = bt_rec if bt_rec
						if param.id
							tb.notModel = param.model
							tb.notId = param.id
						ret += "<div class='row'><p>#{td.header}</p>#{treebox.gen tb}</div>"
					else if td.field
						val = recf td.field
						val = td.val_cb val if td.val_cb
						ret += "<label class='row'"
						ret += " style='position: relative'" if td.validation
						ret += ">"
						ret += "<p>#{td.header}</p>" if td.header
						ret += "<input type='text' name='#{td.field}'"
						if td.format
							ret += " data-format='#{JSON.stringify td.format}'"
							if val
								if td.format.date
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
							ret += " data-validate-was='#{recf td.field}'"
							ret += " data-validate='#{JSON.stringify td.validation}'"
						ret += " onchange='#{onchanges.join ';'}'" if onchanges.length
						ret += ">"
						if td.validation
							ret += "<div class='validation'><p></p></div>"
						ret += "</label>"
					else if td.show
						ret += rec[td.show]
					else if td.checkbox
						ret += "<div class='row'><label class='checkbox'><div><input type='checkbox' name='#{td.checkbox}' onchange='$(this).parent().toggleClass(\"checked\")'></div>"
						ret += "#{td.header}" if td.header
						ret += "</label></div>"
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
								ret += "<div class='textarea-wrap#{if active then active = false; " active" else ''}'><textarea name='#{f.field}'>#{if id then rec[f.field] else ''}</textarea></div>"
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
						ret += "</div><label class='text-center#{if hide then ' hide' else ''}'><div class='btn blue ib'>#{if td.header then " #{td.header}" else ''}</div><input class='hide image-file' onchange='image.upload(this)' name='#{td.image}' type='file'></label>"
					else if td.images
						ret += "<div class='images-form'>"
						for img in images
							ret += "<div>
								<div class='btn remove'></div>
								<a href='#{img.url}' data-lightbox='product'><img src='#{img.url}'></a>
							</div>"
						ret += "</div><label class='text-center'><div class='btn blue ib'>Добавить изображение</div><input class='hide' onchange='image.upload(this)' name='images' type='file' multiple></label>"
					else if td.table
						ret += tableGen td.table, tr_rec, level
					ret += "</#{tag}>"
				ret += "</tr>"
			else
				switch tr.collection.type
					when 'has_many'
						where = {}
						where[name + '_id'] = id
						for rec in models[tr.collection.model].where where
							ret += trGen table, tr, tr_rec.concat(rec), level + 1, true
			ret
		tableGen = (tabls, rec, level) ->
			ret = ""
			for t in tabls
				t.before() if t.before
				ret += "<table"
				if t.attrs
					for k, v of t.attrs
						ret += " #{k}='#{v}'"
				ret += ">"
				for tr in t.tr
					ret += trGen t, tr, rec, level
				ret += "</table>"
			ret
		window.vars = template.vars if template.vars
		window.functions = template.functions if template.functions
		"<a onclick='app.aclick(this)' id='backButton'><i class='icon-arrow-left5'></i><span></span></a>
		<h1 class='title'>#{what 'Добавить запись', 'Редактировать запись'} <b>#{name}</b></h1>
		<form action='model/#{name}/#{action}#{what '', "/#{id}"}' class='content form'><div class='btn green m15' onclick='functions.save(this)'>#{what 'Создать', 'Сохранить'}</div>#{tableGen template.table, [rec], 0}<br><div class='btn green m15' onclick='functions.save(this)'>#{what 'Создать', 'Сохранить'}</div></form><link rel='stylesheet' type='text/css' href='/lightbox/lightbox.min.css'><script src='/tinyMCE/tinymce.min.js'><script src='/lightbox/lightbox.min.js'>"
	else
		"<h2>Отсутствует шаблон формы.</h2><br><a class='btn blue' onclick='app.aclick(this)' href='/admin/model/#{param.model}/templates/form'>Создать</a>"
window.functions =
	save: (el) ->
		unless $('.validation.active').length
			form = $(el).parent()
			data = {record: {}}
			formData = new FormData()
			model = models[param.model]
			$.map form.serializeArray(), (n, i) ->
				value = n.value
				input = form.find("[name='#{n.name}']")
				format = input.data 'format'
				if format
					if format.date
						value = Date.parseExact value, format.date
				data.record[n.name] = value
				formData.append "record[#{n.name}]", value
			$('.tinyMCE').each ->
				el = $ @
				description = tinyMCE.get(@.id).getContent()
				field = el.parent().data 'field'
				data.record[field] = description
				formData.append "record[#{field}]", description
			images = $("[name='images']")
			if images.length
				for image in images[0].files
					formData.append 'images[]', image
			form.find('.image-file').each ->
				file = @.files[0]
				formData.append "image[#{@.name}]", file if file
			if param.id
				form.find('.remove-image').each ->
					el = $ @
					data.removeImage ?= []
					field = el.data 'field'
					data.removeImage.push field
					formData.append "removeImage[#{field}]", el.val()
				record.update model, param.id, data, formData: formData
			else
				record.create model, data, formData: formData
app.after = ->
	if tinymce?
		tinymce.init selector: ".tinyMCE", plugins: 'link image code textcolor', language : 'ru', setup: (editor) ->
			editor.on 'init', (ed) ->
				editor.setContent $(ed.target.editorContainer).next().attr 'value'
	$(".images-form").sortable revert: true
	parent = app.menu.find("[data-route='model/#{param.model}']").addClass('current open').parents('li').eq(0)
	while parent.length
		parent.addClass 'active open'
		parent = parent.parents('li').eq(0)