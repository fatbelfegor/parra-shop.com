@record =
	index: ->
		name = param.model
		model = models[name]
		template = app.templates.index[name]
		ret = ""
		allrecs = model.all()
		if template.order
			for k, v of template.order
				if v is 'asc'
					cb = (a, b) ->
						if a[k] > b[k]
							1
						else if a[k] < b[k]
							-1
						else 0
				else if v is 'desc'
					cb = (a, b) ->
						if a[k] < b[k]
							1
						else if a[k] > b[k]
							-1
						else 0
				allrecs = allrecs.sort cb
		switch template.display
			when 'open-tree'
				recs = []
				for rec in allrecs
					if rec["#{name}_id"] is null
						recs.push rec
				if recs.length
					ret += record.renderRecords all: allrecs, template: template, name: name, subrecs: recs
				else ret += "<h3>Нет записей</h3>"
			else
				if allrecs.length
					ret += record.renderRecords all: allrecs, template: template, name: name
				else ret += "<h3>Нет записей</h3>"
		$('#records').html ret
		window.functions = template.functions if template.functions
		if template.sortable is 'tree'
			$("[data-model-wrap=#{name}]").sortable
				items: "[data-model=#{name}]"
				connectWith: "[data-model-wrap=#{name}]"
				revert: true
				handle: '.sort-handler'
				update: (e, ui) ->
					model_name = $(@).data('modelWrap')
					parent = ui.item.parents('.group').eq(0)
					if parent.length
						parent_id = parent.data 'id'
					else parent_id = 'nil'
					ids = []
					$(@).find("> [data-model='#{model_name}']").each -> ids.push $(@).data 'id'
					$.post '/admin/sort', ids: ids, parent_id: parent_id, model: model_name
	renderRecords: (params) ->
		ret = ""
		switch params.template.display
			when 'open-tree'
				recs = params.subrecs
			else
				recs = params.all
		for rec in recs
			ret += "<div class='group' data-model='#{params.name}' data-id='#{rec.id}'>"
			for t in params.template.table
				ret += "<table>"
				for tr in t.tr
					ret += "<tr"
					if tr.attrs
						for k, v of tr.attrs
							ret += " #{k}=\"#{v}\""
					ret += ">"
					for td in tr.td
						if td.set
							td.set rec
						ret += "<td"
						if td.attrs
							for k, v of td.attrs
								ret += " #{k}=\"#{v}\""
						ret += ">"
						if td.show
							if td.belongs_to
								r = rec[td.belongs_to]()
								val = if r then r[td.show] else ''
							else
								val = rec[td.show]
							if td.format
								if td.format.date
									val = new Date(val).toString td.format.date
							if td.cb
								val = eval(td.cb) val, td.cbParams
							ret += val
						else if td.html
							ret += td.html
						ret += "</td>"
					ret += "</tr>"
				ret += "</table>"
			subrecs = []
			switch params.template.display
				when 'open-tree'
					for r in params.all
						if r["#{params.name}_id"] is rec.id
							subrecs.push r
			ret += "<div class='relations"
			ret += " active" if subrecs.length
			ret += "'>"
			if params.template.relations
				if params.template.relations.close
					for k, v of params.template.relations.close
						ids = rec["#{k}_ids"]
						ret += "<div class='relation-wrap' data-model-wrap='#{k}' data-ids='[#{ids.join ','}]'>
							<div class='relation-header'>#{v.header} (<span class='relations-count'>#{ids.length}</span>)</div>
						</div>"
			if subrecs.length
				ret += "<div class='relation-wrap start' data-model-wrap='#{params.name}'>"
				ret += record.renderRecords all: recs, template: params.template, name: params.name, subrecs: subrecs
				ret += "</div>"
			ret += "</div></div>"
		ret
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
						par.find = ids
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
	update: (mod, id, data, params) ->
		params ?= {}
		if params.formData
			sendData = params.formData
		else sendData = data
		$.ajax
			url: "/admin/model/#{mod.name}/update/#{id}"
			data: sendData
			type: 'POST'
			contentType: false
			processData: false
			dataType: "json"
			success: (res) ->
				notify params.notify or "Запись обновлена"
				for k, v of data.record
					mod.collection[id][k] = v
				if data.removeImage
					for k in data.removeImage
						mod.collection[id][k] = ''
				if res.image
					for k, v of image
						mod.collection[id][k] = v
	create: (mod, data, params) ->
		params ?= {}
		if params.formData
			sendData = params.formData
		else sendData = data
		$.ajax
			url: "/admin/model/#{mod.name}/create"
			data: sendData
			type: 'POST'
			contentType: false
			processData: false
			dataType: "json"
			success: (res) ->
				notify params.notify or "Запись создана"
				data.id = res.id
				if res.image
					for k, v of image
						data[k] = v
				mod.collect data