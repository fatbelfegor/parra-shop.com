app.templates.index.extension =
	page: (recs) ->
		ret = header
			name: 'Статусы товаров'
			header: [['Изображение', '188px'], 'Название', ['Действия', 'min']]
		html = ""
		for rec in recs
			window.rec = rec
			trs = tr show_image('image', attrs: rowspan: 3, style: 'height: 100px') + td('', attrs: colspan: 3)
			trs += tr show('name') + buttons(), attrs: style: 'height: 36px'
			trs += tr td '', attrs: colspan: 3
			html += group trs
		ret + records html