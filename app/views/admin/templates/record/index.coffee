app.routes['model/:model/records'].page = ->
	template = app.templates.index[param.model]
	window[k] = v for k, v of template.functions if template.functions
	cb = ->
		window.model = param.model
		recs = []
		if template.where
			for id, rec of db[param.model].records
				for k, v of template.where
					recs.push rec if rec[k] is v
		else recs.push rec for id, rec of db[param.model].records
		if template.order
			recs.sort (a, b) ->
				if a[template.order] > b[template.order]
					return 1
				if a[template.order] < b[template.order]
					return -1
				0
		app.yield.html template.page recs
		template.after() if template.after
	window.header = (header) ->
		ret = "<div class='group-header'><div>"
		for h in header
			if typeof h is 'string'
				ret += "<p>#{h}</p>"
			else
				ret += "<p style='"
				if h[1]
					ret += "width: "
					if h[1] is 'min'
						ret += '1%; '
					else if h[1] is 'max'
						ret += '100%; '
					else ret += h[1] + '; '
				if h[2]
					ret += "padding: 0 #{h[2]}px"
				ret += "'"
				ret += ">#{h[0]}</p>"
		ret + "</div></div>"
	window.records = (html, params) ->
		params ?= {}
		ret ="<div id='records' data-model-wrap='#{params.model or param.model}'>#{html}</div>"
	window.group = (html, params) ->
		params ?= {}
		ret = "<div class='group' data-model='#{params.model or window.model}' data-id='#{window.rec.id}'><table>#{html}</table>"
		if params.relations
			subrecs = []
			if params.relations.has_self_open
				where = {}
				where[param.model + '_id'] = window.rec.id
				subrecs = db.where param.model, where
			ret += "<div class='relations"
			ret += " active" if subrecs.length
			ret += "'>"
			if params.relations.close
				for k, v of params.relations.close
					ids = window.rec["#{k}_ids"]
					ret += "<div class='relation-wrap' data-model-wrap='#{k}' data-ids='[#{ids.join ','}]' data-render='#{v.render}' data-data='#{JSON.stringify v.data}'>
						<div class='relation-header'>
							<div class='row'>#{if v.header then v.header else ''}</div>
						</div>
					</div>"
			if subrecs.length
				ret += "<div class='relation-wrap start' data-model-wrap='#{param.model}'>"
				ret += params.relations.has_self_open subrecs
				ret += "</div>"
			ret += "</div>"
		ret + "</div>"
	window.rel_header = (header, name) ->
		"<p style='width: 100%'>#{header} (<span class='relations-count'>#{window.rec[name + '_ids'].length}</span>)</p>
		<a class='btn green square' onclick='app.aclick(this)' href='/admin/model/#{name}/new?#{window.model}_id=#{window.rec.id}'>Создать</a>"
	window.tr = (html, params) ->
		ret = "<tr"
		ret += " #{k}='#{v}'" for k, v of params.attrs if params and params.attrs
		ret + ">#{if typeof html is 'string' then html else html.join ''}</tr>"
	window.td = (html, params) ->
		ret = "<td"
		ret += " #{k}='#{v}'" for k, v of params.attrs if params and params.attrs
		ret + ">#{html}</td>"
	window.show_image = (name, params) ->
		url = window.rec[name]
		params ?= {}
		if params.attrs
			if params.attrs.class
				params.attrs.class += ' image'
			else params.attrs.class = 'image'
		else params.attrs = class: 'image'
		td "<a href='#{url}' data-lightbox='#{window.model}'><img src='#{url}'></a>", params
	window.btn_relation = (header, name, params) ->
		attrs = onclick: "relationToggle(this, \"#{name}\")"
		params ?= {}
		params.attrs ?= {}
		attrs.class = 'btn green' unless params.attrs.class
		attrs.style = 'width: 1px' unless params.attrs.style
		attrs.onclick += params.attrs.onclick if params.attrs.onclick
		td "<p>#{header}</p>", attrs: attrs
	window.show = (name, params) ->
		val = window.rec[name]
		if params and params.format
			if params.format.decimal is "currency"
				val = val.toCurrency() + ' руб.'
			else if params.format.date
				val = new Date(val).toString params.format.date
			else if params.format.replace_null
				val = params.format.replace_null if val is null or val is ''
		td "<p>#{val}</p>", params
	window.currency = (name, params) ->
		td "<p>#{window.rec[name].toCurrency() + ' руб.'}</p>", params
	window.new_child = (params) ->
		params ?= {}
		if params.attrs
			if params.attrs.class
				params.attrs.class += ' btn green always'
			else params.attrs.class = 'btn green always'
			if params.style
				params.style = 'width: 1px; ' + params.style
			else params.style = 'width: 1px'
		else
			params.attrs = class: 'btn green always', style: 'width: 1px'
		td "<a onclick='app.aclick(this)' href='/admin/model/#{window.model}/new?#{window.model}_id=#{window.rec.id}'><i class='icon-plus'></i></a>", params
	window.edit = (params) ->
		params ?= {}
		if params.attrs
			if params.attrs.class
				params.attrs.class += ' btn orange always'
			else params.attrs.class = 'btn orange always'
			if params.style
				params.style = 'width: 1px; ' + params.style
			else params.style = 'width: 1px'
		else
			params.attrs = class: 'btn orange always', style: 'width: 1px'
		td "<a onclick='app.aclick(this)' href='/admin/model/#{window.model}/edit/#{window.rec.id}'><i class='icon-pencil3'></i></a>", params
	window.destroy = (params) ->
		params ?= {}
		if params.attrs
			if params.attrs.class
				params.attrs.class += ' btn red always'
			else params.attrs.class = 'btn red always'
			if params.attrs.onclick
				params.attrs.onclick += '; removeRecord(this)'
			if params.style
				params.style = 'width: 1px; ' + params.style
			else params.style = 'width: 1px'
		else
			params.attrs = class: 'btn red always', onclick: 'removeRecord(this)', style: 'width: 1px'
		td "<i class='icon-remove3'></i>", params
	window.drag = (params) ->
		params ?= {}
		if params.attrs
			if params.attrs.class
				params.attrs.class += ' btn lightblue always drag-handler'
			else params.attrs.class = 'btn lightblue always drag-handler'
			if params.style
				params.style = 'width: 1px; ' + params.style
			else params.style = 'width: 1px'
		else
			params.attrs = class: 'btn lightblue always drag-handler', style: 'width: 1px'
		td "<i class='icon-cursor'></i>", params
	window.buttons = (params) -> edit(params) + destroy(params)
	window.relationToggle = (el, rel) ->
		el = $ el
		relations = el.parents('table').eq(0).next()
		wrap = relations.find "> div[data-model-wrap='#{rel}']"
		if wrap.hasClass 'active'
			el.removeClass 'always'
			wrap.removeClass 'active'
			unless relations.find('> .active, > .start').length
				relations.removeClass 'active'
		else
			el.addClass 'always'
			wrap.addClass 'active'
			relations.addClass 'active'
			unless wrap.data 'ready'
				if parseInt(wrap.find('.relations-count').html()) is 0
					wrap.data 'ready', true
				else
					data = wrap.data('data') or {}
					params = model: rel
					params.ids = data.ids if data.ids
					ids = wrap.data 'ids'
					params.find = ids
					db.get params, ->
						window.model = rel
						ret = ""
						render = window[wrap.data 'render']
						for rec in db.find rel, ids
							window.rec = rec
							ret += render()
						wrap.data('ready', true).append ret
	window.removeRecord = (el) ->
		group = $(el).parents('.group').eq(0).attr 'id', 'removeRecord'
		ask "Удалить запись?",
			ok:
				html: "Удалить"
				class: "red"
			action: ->
				group = $('#removeRecord').attr 'id', ''
				model = group.data 'model'
				id = group.data 'id'
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
							group.remove()
							delete db[model].records[id]
							notify "Запись удалена"
			cancel: -> $('#removeRecord').attr 'id', ''
	window.sort = (params) ->
		if params
			if params.parents
				$("[data-model-wrap=#{window.model}]").sortable
					items: "[data-model=#{window.model}]"
					connectWith: "[data-model-wrap=#{window.model}]"
					revert: true
					handle: '.drag-handler'
					update: (e, ui) ->
						wrap = $ @
						parent = wrap.parents('.group').eq(0)
						if parent.length
							parent_id = parent.data 'id'
						else parent_id = 'nil'
						ids = []
						wrap.find("> [data-model='#{window.model}']").each -> ids.push $(@).data 'id'
						$.post '/admin/record/sort_with_parent', ids: ids, parent_id: parent_id, model: window.model
		else
			$("#records").sortable
				items: "[data-model=#{window.model}]"
				revert: true
				handle: '.drag-handler'
				update: (e, ui) ->
					group = $ @
					parent = group.parent()
					ids = []
					parent.find("[data-model=#{window.model}]").each -> ids.push $(@).data 'id'
					$.post '/admin/record/sort_all', ids: ids, model: model
	if template
		if data?
			db.save_many data
			cb()
		else
			rec = model: param.model
			rec.select = template.select if template.select
			rec.belongs_to = template.belongs_to if template.belongs_to
			rec.has_many = template.has_many if template.has_many
			rec.ids = template.ids if template.ids
			get = []
			get.push rec
			get.push p for p in template.get if template.get
			if get.length
				db.get get, cb
			else cb()
	else
		app.yield.html "<h2>Отсутствует шаблон страницы.</h2>"