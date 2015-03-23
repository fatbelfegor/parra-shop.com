app.script = ->
	"models/#{param.model}/index"
app.page = ->
	template = app.templates.index[param.model]
	if template
		ret = "<div style='position: absolute; top: 0; left: 250px; right: 0'><div class='ib records-header'>"
		for t in template.table
			ret += "<table>"
			for tr in t.tr
				ret += "<tr>"
				for td in tr.td
					ret += "<td"
					ret += " colspan='#{td.colspan}'" if td.colspan
					ret += " rowspan='#{td.rowspan}'" if td.rowspan
					ret += ">#{td.header or td.field or td.btn}</td>"
				ret += "</tr>"
			ret += "</table>"
		ret += "</div></div><div id='records' data-model-wrap='#{param.model}'></div>"
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
window.functions =
	relationToggle: (el, rel) ->
		relations = $(el).parents('table').eq(0).next()
		wrap = relations.find "> div[data-model-wrap='#{rel}']"
		if wrap.hasClass 'active'
			wrap.removeClass 'active'
			unless relations.find('> .active, > .start').length
				relations.removeClass 'active'
		else
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