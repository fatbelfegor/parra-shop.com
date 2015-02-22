@record =
	index: ->
		name = param.model
		model = models[name]
		template = model.templates.index
		ret = ""
		for id, rec of model.all()
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
								r = rec[td.belongs_to]()
								val = if r then r[td.field] else ''
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
							ret += " onclick='#{eval(td.btnClick) rec, name}'" if td.btnClick
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
	update: (el) ->
		@send $(el).parent(), 'Запись обновлена', ->
			console.log 'updated'
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
	collect: (mod, rec) ->
		ret = rec
		ret[m] = mod[m] for m in mod.belongs_to
		ret[m] = mod[m] for m in mod.has_many
		mod.collection[rec.id] = ret
	load: (options, cb) ->
		options = [options] unless options[0]
		params = []
		load = false
		pushModel = (m) ->
			if m.has_many
				m.has_many = [m.has_many] unless m.has_many[0]
				for h in m.has_many
					where = {}
					where[m.model + '_id'] = 'ids'
					h.with = [model: m.model, where: where]
					options.push h
					pushModel h
			if m.belongs_to
				m.belongs_to = [m.belongs_to] unless m.belongs_to[0]
				for h in m.belongs_to
					h.with = [model: m.model, find: h.model + '_id']
					options.push h
					pushModel h
		pushModel m for m in options
		for m in options
			load = false
			model = models[m.model]
			par = {model: model.name}
			par.all = false
			if m.find
				if typeof m.find is 'object'
					ids = []
					for id in m.find
						ids.push id unless model.find id
					if ids.length > 0
						m.find = ids
						load = true
				else if !model.find(m.find)
					par.find = m.find
					load = true
			else if m.where
				for k, v of m.where
					if v is null
						unless k in model.ready.null
							model.ready.null.push k
							par.null ?= []
							par.null.push k
							load = true
					else
						if model.ready.where[k]
							unless v in model.ready.where[k]
								model.ready.where[k].push v
								par.where ?= {}
								par.where[k] = v
								load = true
						else
							model.ready.where[k] = [v]
							par.where ?= {}
							par.where[k] = v
							load = true
			else if m.with
				par.with = m.with
				load = true
			else
				par.all = true
				load = true
			par.collect = m.collect if m.collect
			if m.has_many
				par.collect ||= []
				par.collect.push 'ids'
			if m.belongs_to
				par.collect ||= []
				for h in m.belongs_to
					par.collect.push h.model + '_id'
			par.ids = m.ids if m.ids
			params.push par if load
		if load
			post 'record/get', models: params, (res) ->
				collect = {}
				for m in params
					model = models[m.model]
					model_res = res[m.model]
					if m.find
					else if m.where
						for k, v in m.where
							console.log k, v
					else if m.with
						for h in m.with
							c = collect[h.model]
							if h.where
								for k, v of h.where
									model.ready.where[k] = (model.ready.where[k] || []).concat c[v]
					else
						model.ready.all = true
					for rec in model_res.model
						model.collect rec
					if m.collect
						collect[m.model] = {}
						for f in m.collect
							if f is 'ids'
								collect[m.model].ids = []
								for rec in model_res.model
									collect[m.model].ids.push rec.id
				cb()
		else
			cb()
	all: (mod) ->
		ret = []
		ret.push rec for id, rec of mod.collection
		ret
	belongs_to: (model, rec) ->
		models[model].find(rec[model + '_id'])
	has_many: (name, model, rec) ->
		ret = []
		for k, v of models
			if v.pluralize is model
				for id, r of v.collection
					ret.push r if r[name + '_id'] is rec.id
				break
		ret
	find: (mod, ids) ->
		type = typeof ids
		if type is 'object'
			ret = []
			if ids
				for id in ids
					rec = mod.collection[id]
					ret.push rec if rec
			if ret.length then ret else false
		else
			if type is 'string'
				ids = parseInt ids
			mod.collection[ids] or null
	where: (mod, params) ->
		ret = []
		for id, rec of mod.collection
			for k, v of params
				if rec[k] is v
					ret.push rec
		ret
	create: (mod, params, msg, cb) ->
		@cb = cb
		post "model/#{mod.name}/create", record: params, (id) ->
			notify msg or 'Запись успешно создана'
			params.id = id
			mod.collect params
			record.cb id if record.cb
	destroy: (mod, id, params) ->
		params ?= {}
		ask (params.msg or 'Удалить запись?'), (d) ->
			delete mod.collection[d.id]
			post "model/#{mod.name}/destroy/#{d.id}"
			params = d.params
			if params.cb
				if params.cb_data
					params.cb params.cb_data
				else params.cb()
		, id: id, params: params