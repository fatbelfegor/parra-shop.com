@record =
	index: ->
		name = app.data.route.model
		table = tables[name]
		template = models["#{name}_index"]
		ret = ""
		for rec in table.records
			ret += "<div class='group'>"
			for t in template.table
				ret += "<table>"
				for tr in t.tr
					ret += "<tr>"
					for td in tr.td
						ret += "<td"
						ret += " colspan='#{td.colspan}'" if td.colspan
						ret += " rowspan='#{td.rowspan}'" if td.rowspan
						if td.btn
							ret += " class='btn"
							if td.btn is 'edit'
								ret += " orange'"
							else if td.btn is 'remove'
								ret += " red'"
						ret += ">"
						ret += rec[td.field] if td.field
						ret += "<a href='/admin/model/#{name}/edit/#{rec.id}' class='edit' onclick='app.aclick(this)'></a>" if td.btn and td.btn is 'edit'
						ret += "<div class='remove'></div>" if td.btn and td.btn is 'remove'
						ret += "</td>"
					ret += "</tr>"
				ret += "</table>"
			ret += "</div>"
		$('#records').html ret
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
		models = []
		for d, i in data
			table = tables[d.model]
			d.has_self = true if table.has_self
			load = false
			unless table.full.all
				if d.where
					for k, v of d.where
						if table.full[k]
							if v not in table.full[k]
								load = true
								table.full[k].push v
						else
							load = true
							table.full[k] = [v]
				else
					load = true
					table.full.all = true
			models.push d if load
		if models.length > 0
			post "record/get", models: models, (res) ->
				for m, r of res
					table = tables[m]
					$.extend true, tables[k].records, v for k, v of r.belongs_to if r.belongs_to
					$.extend true, tables[k].records, v for k, v of r.has_many if r.has_many
					table.records = table.records.concat r.records
					table.children = table.children.concat r.children if table.has_self
					table.habtm[k] = table.habtm[k].concat v for k, v of r.habtm if r.habtm
				success() if success
		else if already
			already()
		else if success
			success()
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
			if wrap then wrap rec[c.name] else rec[c.name]
		else
			if c.default
				if wrap then wrap c.default else c.default
			else
				''
	val: (rec, c) ->
		@col rec, c, (val) -> " value='#{val}'"
	destroy: (name, id) ->
		send "model/#{name}/destroy/#{id}", {}, "Запись удалена"
	btnDestroy: (el) ->
		rec = $(el).parent()
		@destroy rec.data('model'), rec.data 'id'
		rec.remove()
	find: (recs, id, options) ->
		recs = tables[recs]
		for item, i in recs.records
			if item.id is id
				if options and options.habtm
					item = record: item, habtm: {}
					for m in options.habtm
						item.habtm[m] = recs.habtm[m][i]
				return item
	where: (recs, options) ->
		ret = records: []
		options ||= {}
		if options.children
			children = tables[recs].children
			ret.children = []
		if options.habtm
			habtm = tables[recs].habtm
			ret.habtm = {}
			ret.habtm[model] = [] for model in options.habtm
		options.where ||= {}
		for item, i in tables[recs].records
			push = true
			if options.where
				for k, v of options.where
					if item[k] isnt v
						push = false
						break
			if options.in
				for k, v of options.in
					if item[k] not in v
						push = false
						break
			if push
				ret.records.push item
				ret.children.push children[i] if options.children
				if options.habtm
					for m in options.habtm
						ret.habtm[m].push habtm[m][i]
		ret