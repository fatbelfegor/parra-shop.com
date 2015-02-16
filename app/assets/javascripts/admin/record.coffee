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
						ret += " style='#{td.style}'" if td.style
						if td.btn
							ret += " class='btn"
							ret += " #{td.btnTdClass}" if td.btnTdClass
							ret += "'"
						ret += ">"
						if td.field
							if td.belongs_to
								val = @find td.belongs_to, rec[td.belongs_to + '_id']
								if val then val = val[td.field] else val = ''
							else
								val = rec[td.field]
							if td.cb
								val = eval(td.cb) val, td.cbParams
							ret += val
						else if td.btn
							if td.btnA
								tag = "a"
							else tag = "div"
							ret += "<#{tag}"
							ret += " href='#{eval(td.btnA) rec, name}'" if td.btnA
							ret += " onclick='#{td.btnClick}'" if td.btnClick
							ret += " class='#{td.btnClass}'" if td.btnClass
							ret += ">"
							ret += "<i class='#{td.btnIcon}'></i>" if td.btnIcon
							ret += "</#{tag}>"
						else if td.func
							ret += eval(td.func) rec
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
		data = [data] unless data.length
		cb = already ? success
		return cb() if data[0].length is 0
		models = []
		genModel = (d) ->
			table = tables[d.model]
			load = false
			m = model: d.model
			unless table.full.all
				if d.find
					if d.find in table.full.id
						m.ids = [d.find] if d.has_many or d.belongs_to
					else
						load = true
						table.full.id.push d.find
						m.find = d.find
				else if d.where
					for k, v of d.where
						if table.full[k]
							if v not in table.full[k]
								load = true
								table.full[k].push v
						else
							load = true
							table.full[k] = [v]
					m.where = d.where
				else
					load = true
					table.full.all = true
			m.load = load
			if d.has_many
				for h in d.has_many
					unless table.has_many[h.model]
						load = true
						table.has_many[h.model] = true
						h = genModel h
						if h.load
							m.has_many ||= []
							m.has_many.push h.model
			if d.belongs_to
				for h in d.belongs_to
					unless table.belongs_to[h.model]
						load = true
						table.belongs_to[h.model] = true
						h = genModel h
						if h.load
							m.belongs_to ||= []
							m.belongs_to.push h.model
			model: m, load: load
		for d, i in data
			m = genModel d
			models.push m.model if m.load
		if models.length > 0
			post "record/get", models: models, (res) ->
				setModel = (res) ->
					for m, r of res
						table = tables[m]
						if r.records
							table.records = table.records.concat r.records
							table.children = table.children.concat r.children if r.children
						setModel r.belongs_to if r.belongs_to
						setModel r.has_many if r.has_many
						table.habtm[k] = table.habtm[k].concat v for k, v of r.habtm if r.habtm
				setModel res
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