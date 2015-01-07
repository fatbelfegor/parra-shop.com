@component =
	setup: (el) ->
		$(el).parent().parent().toggleClass 'active'
	create: (el) ->
		el = $ el
		el.addClass 'loading'
		act.form el.parents('form'), 'Компонент установлен', (d) ->
			if d
				el.removeClass 'loading'