app.templates.index.banner =
	page: (recs) ->
		ret = header
		 	name: 'Баннеры'
		 	header: [['Изображение', '188px'], 'url', ['Действия', 'min']]
		html = ""
		for rec in recs
			window.rec = rec
			tr_html = tr show_image('image', attrs: rowspan: 3, style: 'height: 100px') + td('', attrs: colspan: 3)
			tr_html += tr show('url') + buttons(), attrs: style: 'height: 36px'
			tr_html += tr td '', attrs: colspan: 3
			html += group tr_html
		ret + records html