app.preload = ->
	id = parseInt app.data.route.id
	name = app.data.route.model
	template = models[name + "_form"]
	ret = []
	if id
		rec = model: name, find: id
		rec.has_many = template.has_many if template.has_many
		ret.push rec
	if template.preload
		for m in template.preload
			ret.push m
	ret
app.page = ->
	name = app.data.route.model
	id = parseInt app.data.route.id
	table = tables[name]
	rec = record.find name, id if id
	images = record.where 'image', {imageable_type: table.name, imageable_id: id} if 'image' in table.has_many
	what = (c, u) ->
		if id then u else c
	action = what 'create', 'update'
	recf = (k) ->
		if id then rec[k] else ''
	trGen = (table, tr, tr_rec, level, collection) ->
		ret = ""
		if collection or !tr.collection
			if tr.before
				tr.before table: table, recs: tr_rec, rec: tr_rec[level]
			ret += "<tr>"
			for td in tr.td
				continue if td.only and td.only isnt action
				if id and td.belongs_to
					rec = record.find td.belongs_to, tr_rec[td.level || level]["#{td.belongs_to}_id"]
				else rec = tr_rec[td.level || level]
				if td.th
					tag = 'th'
				else tag = 'td'
				ret += "<#{tag}"
				ret += " colspan='#{td.colspan}'" if td.colspan
				ret += " rowspan='#{td.rowspan}'" if td.rowspan
				ret += " class='#{td.class}'" if td.class
				ret += " style='#{td.style}'" if td.style
				ret += ">"
				if td.treebox
					tb = td.treebox
					tb.tag = 'div'
					tb.style = 'width: 100%'
					tb.input = name: "record[#{td.field}]"
					tb.classes = td.class.concat td.class.split(' ') if td.class
					tb_rec = tb.rec table: table, recs: tr_rec, rec: rec
					ret += "<div class='row'><p>#{td.header}</p>#{treebox.gen tb, tb_rec}</div>"
				else if td.field
					val = recf td.field
					val = td.val_cb val if td.val_cb
					ret += "<label class='row'>"
					ret += "<p>#{td.header}</p>" if td.header
					ret += "<input type='text' name='record[#{td.field}]'"
					ret += " value='#{val}'" if val
					ret += "></label>"
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
				else if td.show
					if td.cb
						ret += td.cb rec[td.show]
					else ret += rec[td.show]
				else if id and td.cb
					ret += td.cb table: table, tr: tr, rec: rec, recs: tr_rec
				ret += "</#{tag}>"
			ret += "</tr>"
		else
			switch tr.collection.type
				when 'has_many'
					where = {}
					where[name + '_id'] = id
					for rec in record.where(tr.collection.model, where: where).records
						ret += trGen table, tr, tr_rec.concat(rec), level + 1, true
		ret
	tableGen = (tabls, rec, level) ->
		ret = ""
		for t in tabls
			t.before() if t.before
			ret += "<table"
			ret += " class='#{t.class}'" if t.class
			ret += ">"
			for tr in t.tr
				ret += trGen t, tr, rec, level
			ret += "</table>"
		ret
	template = models[name + "_form"]
	window.vars = template.vars if template.vars
	"<a onclick='app.aclick(this)' id='backButton'><i class='icon-arrow-left5'></i><span></span></a>
	<h1 class='title'>#{what 'Добавить запись', 'Редактировать запись'} <b>#{word name}</b></h1>
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