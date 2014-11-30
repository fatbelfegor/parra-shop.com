@sliderLeft = (el) ->
	div = $(el).next().find '> div'
	slides = div.find '.slide'
	move = slides.last()
	if div.css('left') == '0px'
		div.css('left': "-#{move.outerWidth()}px").prepend(move.clone()).animate 'left': 0, 1000, ->
			move.remove()
@sliderRight = (el) ->
	div = $(el).prev().find '> div'
	slides = div.find '.slide'
	move = slides.first()
	div.append(move.clone()).animate 'left': "-#{move.outerWidth()}px", 1000, ->
		div.css('left': 0)
		move.remove()