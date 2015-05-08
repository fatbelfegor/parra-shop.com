app.templates.index.page =
	page: (recs) ->
		ret = header
			name: 'Страницы'
			header: [['URL', '30%'], 'Название', ['Действия', 'min']]
		html = ""
		for rec in recs
			window.rec = rec
			html += group tr [
				show "url", attrs: style: 'width: 30%'
				show "name"
				buttons()
			]
		ret + records html