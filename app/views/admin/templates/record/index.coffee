app.page = ->
	model = app.data.route.model
	table = tables[model]
	ret = "<div id='records' data-wrap='main' data-records='#{model}'></div>"
	ret
app.after = ->
	name = app.data.route.model
	data = {model: name}
	template = settings.template.index.model[name]
	if template
		for c in template.string
			if c.belongs_to
				data.belongs_to ||= []
				data.belongs_to.push c.belongs_to if data.belongs_to.indexOf c.belongs_to > -1
		data.has_many = template.has_many if template.has_many
	record.ask data, ->
		record.refresh $ '#records'