@record =
	refresh: (wrap) ->
		name = wrap.data 'records'
		table = tables[name]
		template = settings.template.index.model[name] or settings.template.index.common
		width = 100 / table.fields.string.length
		string = table.fields.string
		text = table.fields.text
		records = table.records
		if name is 'order'
			records = records.sort (a, b) ->
				if new Date(a.created_at).getTime() < new Date(b.created_at).getTime()
					1
				else
					-1
		children = table.children if table.has_self
		ret = ''
		switch wrap.data 'wrap'
			when 'main'
				ret = "<div data-records-header='#{name}' class='header'><div><div>"
				for c in string
					if c.belongs_to
						ret += "<p>#{word c.belongs_to}: #{word c.name}</p>"
					else if c.custom
						ret += "<p>#{c.title}</p>"
					else
						ret += "<p>#{word c.name}</p>"
				ret += "</div>"
				for field in text
					ret += "<div><p>#{word field}</p></div>"
				ret += "</div></div>"
				if table.has_self
					recs = []
					chis = []
					for rec, i in records
						if !rec["#{name}_id"]
							recs.push rec
							chis.push children[i]
				else
					recs = records
			when 'children'
				recs = []
				chis = []
				for rec, i in records
					if rec["#{name}_id"] is id
						recs.push rec
						chis.push children[i]
			when 'relation'
				if wrap.html() is ''
					ret = "<div class='model-name'>#{name}</div>"
					relations = wrap.parent()
					id = relations.data 'parentId'
					parent_model = relations.parent().data 'model'
					recs = []
					chis = [] if table.has_self
					for rec, i in records
						if rec["#{parent_model}_id"] is id
							recs.push rec
							chis.push children[i] if table.has_self
				else
					records = []
		for rec, i in recs
			children = table.has_self and chis[i] > 0
			ret += "<div data-model='#{name}' data-id='#{rec.id}' class='record-wrap'>"
			ret += "<div class='btn btn-children' onclick='record.children(this)'></div>" if children
			ret += "<div class='btn btn-destroy' onclick='record.btnDestroy(this)'></div>"
			ret += btn rec for btn in template.buttons if template.buttons
			if template.buttons then btnpx = template.buttons.length else btnpx = 0
			ret += "<div class='record' style='margin: 0 #{(btnpx + 1) * 39}px 0 0'><a onclick='app.aclick(this)' href='/admin/model/#{name}/edit/#{rec.id}' class='string'>"
			for c in string
				if c.belongs_to
					bt_id = c.belongs_to + '_id'
					if tables[c.belongs_to].records.length is 0
						val = ''
					else
						bt_id_val = rec[bt_id]
						if bt_id_val
							val = tables[c.belongs_to].records.filter((c) -> c.id is bt_id_val)[0][c.name]
						else
							val = "Не задан #{word tables[c.belongs_to].singularize}"
				else if c.custom
					val = eval c.cb
				else
					val = rec[c.name]
				switch c.type
					when 'datetime'
						d = new Date val
						date = d.getDate()
						date = '0' + date if date < 10
						month = d.getMonth() + 1
						month = '0' + month if month < 10
						val = "#{date}.#{month}.#{d.getFullYear()}"
				ret += "<p style='width: #{width}%'>#{val}</p>"
			ret += "</a>"
			for field in text
				ret += "<div class='text'>#{rec[field]}</div>"
			ret += "<!--<div data-parent-id='#{rec.id}' class='relations'>"
			for rel in table.has_many
				for k, t of tables
					if t.pluralize is rel
						ret += "<div class='relation' data-records='#{t.singularize}' data-wrap='relation'></div>"
			ret += "</div>--></div>"
			ret += "<div data-records='#{name}' data-wrap='children' data-parent-id='#{rec.id}' class='children'></div>" if children
			ret += "</div>"
		wrap.html ret
	children: (el) ->
		el = $ el
		parent = el.parent()
		childrenWrap = parent.find('> .children')
		if el.hasClass 'active'
			el.removeClass 'active'
			childrenWrap.removeClass 'active'
		else
			el.addClass 'active'
			childrenWrap.addClass 'active'
			record.loadChildren parent.data('model'), parent.data('id'), ->
				record.refresh childrenWrap
	send: (form, msg, cb) ->
		validate form, ->
			form.find('.tinyMCE').each ->
				@.value = tinymce.get(@.id).getContent()
			act.form form, msg, cb
	create: (el) ->
		@send $(el).parent(), 'Запись создана', (id) ->
			console.log id
	update: (el) ->
		@send $(el).parent(), 'Запись обновлена', ->
			console.log 'updated'
	ask: (data, success, already) ->
		data = [data] unless data[0]
		load = false
		models = []
		for d, i in data
			name = d.model
			table = tables[name]
			if !table.full.all
				if table.has_self
					unless table.full["#{name}_id"] and table.full["#{name}_id"][data.has_self]
						load = true
						table.full["#{name}_id"] ||= {}
						table.full["#{name}_id"][d.has_self] = true
						d.where = {}
						if d.has_self is null
							d.has_self_null = true
						else
							d.where["#{name}_id"] = d.has_self
						d.has_self = true
				else
					load = true
					table.full.all = true
				models.push d
		if load
			act.post "record/get", models: models, (res) ->
				for m, r of res
					table = tables[m]
					$.extend true, tables[k].records, v for k, v of r.belongs_to if r.belongs_to
					$.extend true, tables[k].records, v for k, v of r.has_many if r.has_many
					$.extend true, table.records, r.records
					table.children = table.children.concat r.children if table.has_self
				success name if success
		else if already
			already name
		else if success
			success name
	loadChildren: (name, id, success, already) ->
		@ask {model: name, has_self: id}, success, already
	treebox: (el, name) ->
		treebox.toggle el
		el = $ el
		id = el.next().data 'val'
		ul = el.parent().next()
		record.loadChildren name, id, (name) ->
			records = []
			table = tables[name]
			for rec in table.records
				if rec["#{name}_id"] is id
					records.push rec
			ret = ''
			for rec in records
				ret += "<li>"
				if rec.children > 0
					ret += "<div><i class='icon-arrow-down2' onclick='record.treebox(this, \"#{name}\")'></i><p onclick='treebox.pick(this)' data-val='#{rec.id}'>#{rec.name}</p></div><ul></ul>"
				else
					ret += "<div><p onclick='treebox.pick(this)' data-val='#{rec.id}'>#{rec.name}</p></div>"
				ret += "</li>"
			ul.html ret
	col: (rec, c, wrap) ->
		if rec
			if wrap then wrap(rec[c.name] || '') else rec[c.name]
		else
			if c.default
				if wrap then wrap c.default else c.default
			else
				''
	val: (rec, c) ->
		@col rec, c, (val) -> " value='#{val}'"
	destroy: (name, id) ->
		act.sendData "model/#{name}/destroy/#{id}", {}, "Запись удалена"
	btnDestroy: (el) ->
		rec = $(el).parent()
		@destroy rec.data('model'), rec.data 'id'
		rec.remove()
	find: (recs, id) ->
		return item if item.id is parseInt id for item in recs
	where: (recs, scope) ->
		recs.filter (r) ->
		for rec in tables.category.records
			if !rec.parent_id
				cats.push rec