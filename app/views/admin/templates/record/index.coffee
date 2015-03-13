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
			<a class='btn blue' onclick='app.aclick(this)' href='/admin/model/category/templates/index'>Создать шаблон</a>
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
		record.load options, record.index