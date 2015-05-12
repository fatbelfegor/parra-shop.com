app.templates.index.status =
	page: (recs) ->
		ret = ""
		for rec in recs
			window.rec = rec
			ret += renderStatus()
		header({name: 'Статусы заказов', save: false, header: [['Название', 'max'], ['Действия', '225px']]}) + records ret + add 'renderStatus'
	functions:
		renderStatus: -> group tr td(field('', "name", validation: presence: true)) + save() + destroy()