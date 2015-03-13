app.preload = ->
	id = parseInt param.id
	name = param.model
	template = models[name].templates.form
	ret = []
	if id
		rec = model: name, find: id
		rec.belongs_to = template.belongs_to if template.belongs_to
		rec.has_many = template.has_many if template.has_many
		ret.push rec
	ret
app.page = ->
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
					tb.input = name: "record[#{td.field}]"
					tb.classes = td.class.concat td.class.split(' ') if td.class
					tb.rec = rec if id
					ret += "<div class='row'><p>#{td.header}</p>#{treebox.gen tb}</div>"
				else if td.field
					val = recf td.field
					val = td.val_cb val if td.val_cb
					ret += "<label class='row'>"
					ret += "<p>#{td.header}</p>" if td.header
					ret += "<input type='text' name='record[#{td.field}]'"
					ret += " value='#{val}'" if val
					if td.fieldAttrs
						for k, v of td.fieldAttrs
							ret += " #{k}='#{v}'"
					ret += "></label>"
				else if td.show
					ret += rec[td.show]
				else if td.checkbox
					ret += "<div class='row'><label class='checkbox'><div><input type='checkbox' name='record[#{td.checkbox}]' onchange='$(this).parent().toggleClass(\"checked\")'></div>"
					ret += "#{td.header}" if td.header
					ret += "</label></div>"
				else if td.html
					ret += td.html
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
	template = model.templates.form
	window.vars = template.vars if template.vars
	window.functions = template.functions if template.functions
	"<a onclick='app.aclick(this)' id='backButton'><i class='icon-arrow-left5'></i><span></span></a>
	<h1 class='title'>#{what 'Добавить запись', 'Редактировать запись'} <b>#{name}</b></h1>
	<form action='model/#{name}/#{action}#{what '', "/#{id}"}' class='content form'><div class='btn green m15' onclick='recordFormSubmit(this)'>#{what 'Создать', 'Сохранить'}</div>#{tableGen template.table, [rec], 0}<br><div class='btn green m15' onclick='recordFormSubmit(this)'>#{what 'Создать', 'Сохранить'}</div></form><link rel='stylesheet' type='text/css' href='/lightbox/lightbox.min.css'><script src='/tinyMCE/tinymce.min.js'><script src='/lightbox/lightbox.min.js'>"
window.recordFormSubmit = (el) ->
	msg = if app.data.route.id then 'Запись успешно сохранена' else 'Запись успешно создана'
	form = $(el).parent()
	data = form.serializeArray()
	send form.attr('action'), data, msg, (id) ->
		name = app.data.route.model
		table = tables[name]
		if app.data.route.id
			for rec in table.records
				if rec.id is id
					for f in data
						rec[f.name[7..-2]] = f.value
					break
		else
			rec = id: id
			for f in data
				rec[f.name[7..-2]] = f.value
			table.records.push rec
			app.redirect "/admin/model/order/edit/#{id}"
app.after = ->
	tinymce.init selector: ".tinyMCE", plugins: 'link image code textcolor', language : 'ru'
	$(".images-form").sortable revert: true