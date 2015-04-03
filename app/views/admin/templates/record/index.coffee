app.page = ->
	template = app.templates.index[param.model]
	@functions[k] = v for k, v of template.functions if template.functions
	if template
		ret = ""
		if template.header
			ret += "<div class='group-header'><div>"
			for h in template.header
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
			ret += "</div></div>"
		ret += "<div id='records' data-model-wrap='#{param.model}'></div>"
	else
		ret = "<div class='content'>
			<br>
			<h3>Шаблона этой страницы не существует.</h3>
			<br>
			<a class='btn blue' onclick='app.aclick(this)' href='/admin/model/#{param.model}/templates/index'>Создать шаблон</a>
			<br>
			<br>
		</div>"
	ret
app.after = ->
	model = models[param.model]
	template = app.templates.index[param.model]
	if template
		options = model: model.name
		options.belongs_to = template.belongs_to if template.belongs_to
		options.has_many = template.has_many if template.has_many
		if template.relations
			if template.relations.close
				options.ids = []
				for k of template.relations.close
					options.ids.push k
		record.load options, record.index
	parent = app.menu.find("[data-route='model/#{param.model}']").addClass('current open').parents('li').eq(0)
	while parent.length
		parent.addClass 'active open'
		parent = parent.parents('li').eq(0)
app.functions =
	relationToggle: (el, rel) ->
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
					model_name = wrap.data 'modelWrap'
					model = models[model_name]
					template = app.templates.index[model_name]
					if template
						options = model: model_name
						options.belongs_to = template.belongs_to if template.belongs_to
						options.has_many = template.has_many if template.has_many
						ids = wrap.data 'ids'
						options.find = ids
						if template.relations
							if template.relations.close
								options.ids = []
								for k of template.relations.close
									options.ids.push k
						record.load options, ->
							wrap.data('ready', true).append record.renderRecords all: model.find(ids), template: template, name: model_name
	removeRecord: (el) ->
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
							delete models[model].collection[id]
							notify "Запись удалена"
			cancel: -> $('#removeRecord').attr 'id', ''