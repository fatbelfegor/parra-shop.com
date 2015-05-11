app.templates.index.banner =
	page: (recs) ->
		ret = header
		 	name: 'Баннеры'
		 	header: [['Изображение', '188px'], 'url', ['Действия', 'min']]
		 	save: false
		html = ""
		for rec in recs
			window.rec = rec
			html += renderBanner()
		ret + records html + add 'renderBanner'
	functions:
		renderBanner: ->
			ret = tr show_image('image', {attrs: rowspan: 3, style: 'height: 100px'}, 'Добавить изображение') + td('', attrs: style: 'border-width: 1px 0 0') + td('&nbsp;', attrs: colspan: 2, style: 'border-width: 1px')
			ret += tr td(field '', 'url', attrs: style: 'max-width: 350px') + save(attrs: style: 'border-width: 0 0 0 1px') + destroy(), attrs: style: 'height: 36px'
			ret += tr td('', attrs: style: 'border-width: 0 0 1px') + td('&nbsp;', attrs: colspan: 2, style: 'border-width: 1px')
			group ret, attrs: class: 'no-border'