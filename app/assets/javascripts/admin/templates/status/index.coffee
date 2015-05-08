app.templates.index.status =
	page: (recs) ->
		ret = ""
		for rec in recs
			window.rec = rec
			ret += group tr show("name") + buttons()
		header({name: 'Статусы заказов', header: [['Название', 'max'], ['Действия', '225px']]}) + records ret