app.page = ->
	template = models[param.model].templates.index
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
	ret += "</div></div><div style='padding: 85px 50px 50px' id='records'></div>"
	ret
app.after = ->
	model = models[param.model]
	template = model.templates.index
	options = model: model.name
	options.belongs_to = template.belongs_to if template.belongs_to
	options.has_many = template.has_many if template.has_many
	record.load options, record.index