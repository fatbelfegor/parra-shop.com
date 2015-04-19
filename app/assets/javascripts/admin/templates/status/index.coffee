app.templates.index.status =
	page: (recs) ->
		ret = ""
		for rec in recs
			window.rec = rec
			ret += group tr show("name") + buttons()
		header(['Название', ['Действия', '225px']]) + records ret