@treebox =
	show: (el) ->
		$(el).parent().toggleClass 'open'
	open: (el) ->
		li = $(el).parents('li').first()
		if li.hasClass 'open'
			li.removeClass 'open'
			$(el).toggleClass 'icon-arrow-up icon-arrow-down'
		else
			li.addClass 'open'
			$(el).toggleClass 'icon-arrow-down icon-arrow-up'
	pick: (el) ->
		val = $(el).html()
		treebox = $(el).parents('.treebox').removeClass('open')
		treebox.find('.button p').html val
		treebox.find('input').val $(el).data 'id'