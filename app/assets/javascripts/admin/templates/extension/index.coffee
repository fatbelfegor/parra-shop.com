app.templates.index.extension =
	page: (recs) ->
		ret = header
			name: 'Статусы товаров'
			header: [['Изображение', '188px'], 'Название', ['Действия', 'min']]
			save: false
		html = ""
		for rec in recs
			window.rec = rec
			html += renderExtension()
		ret + records html + add 'renderExtension'
	functions:
		renderExtension: ->
			trs = tr td(image_wrap(), {attrs: rowspan: 3, style: 'width: 1px; height: 100px'}) + td('', attrs: style: 'border-width: 1px 0 0') + td('&nbsp;', attrs: colspan: 2, style: 'border-width: 1px')
			trs += tr td(field('', 'name', validation: {presence: true}, attrs: style: 'max-width: 350px'), attrs: style: 'border-width: 0') + save() + destroy(), attrs: style: 'height: 36px'
			trs += tr td('', attrs: style: 'border-width: 0 0 1px') + td('&nbsp;', attrs: colspan: 2, style: 'border-width: 1px')
			group trs