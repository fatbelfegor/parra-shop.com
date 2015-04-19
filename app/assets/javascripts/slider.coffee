@sliderPrev = (el) ->
	products = $(el).next()
	active = products.find('.active').removeClass('active')
	move = active.removeClass('active').prev()
	unless move[0]
		move = products.find('> :last-child')
	if parseInt(move.css('left')) > 0
		move.css left: '-100%', right: '100%'
	active.animate {left: '100%', right: '-100%'}, 1000
	move.addClass('active').animate {left: '0', right: '0'}, 1000	
	buttons = $(el).parent().find('.buttons')
	buttonPrev = buttons.find('.active').removeClass('active').prev()
	if buttonPrev[0]
		buttonPrev.addClass('active')
	else
		buttons.find('> :last-child').addClass('active')
@sliderNext = (el, slide) ->
	products = $(el).prev()
	active = products.find('.active')
	move = active.removeClass('active').next()
	unless move[0]
		move = products.find('> :first-child')
	if parseInt(move.css('left')) < 0
		move.css left: '100%', right: '-100%'
	active.animate {left: '-100%', right: '100%'}, 1000
	move.addClass('active').animate {left: '0', right: '0'}, 1000
	buttons = $(el).parent().find('.buttons')
	buttonNext = buttons.find('.active').removeClass('active').next()
	if buttonNext[0]
		buttonNext.addClass('active')
	else
		buttons.find('> :first-child').addClass('active')
sliderLeft = (steps, products) ->
	active = products.find('.active').removeClass('active')
	move = active.prev()
	time = 1000 / steps
	for i in [1..steps]
		unless move[0]
			move = products.find('> :last-child')
		if parseInt(move.css('left')) > 0
			move.css left: '-100%', right: '100%'
		delay = (i-1) * time
		active.animate {left: '100%', right: '-100%'}, time, 'linear'
		move.delay(delay).animate {left: '0', right: '0'}, time, 'linear'
		active = move
		move = active.prev()
	active.addClass('active')
sliderRight = (steps, products) ->
	active = products.find('.active').removeClass('active')
	move = active.next()
	time = 1000 / steps
	for i in [1..steps]
		unless move[0]
			move = products.find('> :first-child')
		if parseInt(move.css('left')) < 0
			move.css left: '100%', right: '-100%'
		delay = (i-1) * time
		active.animate {left: '-100%', right: '100%'}, time, 'linear'
		move.delay(delay).animate {left: '0', right: '0'}, time, 'linear'
		active = move
		move = active.next()
	active.addClass('active')
@sliderChoose = (el) ->
	unless $(el).hasClass('.active')
		buttons = $(el).parent()
		products = buttons.prev().prev()
		active = buttons.find('.active').removeClass('active')
		count = buttons.find('div').length
		start = active.index()
		end = $(el).addClass('active').index()
		if end > start
			if count / (count - end + start) > 2
				sliderLeft count - end + start, products
			else
				sliderRight end - start, products
		else
			if count / (count - start + end) < 2
				sliderLeft start - end, products
			else
				sliderRight count - start + end, products
@slider = ->
	next = $('#slider .next')
	@sliderInterval = setInterval ->
		sliderNext next, true
	, 5000