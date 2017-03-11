product = size = color = texture = option = sizes = colors = textures = options = undefined

@tabs = (el) ->
	el = $(el)
	unless el.hasClass 'active'
		tabs = el.parent()
		tabs.find('.active').removeClass 'active'
		el.addClass 'active'
		pages = tabs.next()
		pages.find('.active').removeClass 'active'
		pages.find('> div').eq(el.index()).addClass 'active'

setOption = (i) ->
	if options = size.options
		option = options[i]

setTexture = (i) ->
	if textures = color.textures
		texture = textures[i]

setColor = (i) ->
	if colors = size.prcolors
		color = colors[i]
		setTexture 0

setSize = (i) ->
	if sizes = product.prsizes
		size = sizes[i]
		setColor 0
		setOption 0
		colorNav.style.display = colors and 'inline-block' or 'none'
		optionNav.style.display = options and 'inline-block' or 'none'

refresh = ->
	price = product.price
	old_price = product.old_price if product.old_price
	if size
		sizeP.style.display = 'block'
		price += +size.price
		if old_price
			if size.old_price
				old_price += +size.old_price
			else old_price += +size.price
		sizeB.innerHTML = size.name
		if color
			colorP.style.display = 'block'
			price += +color.price
			old_price += +color.price if old_price
			if texture
				price += +texture.price
				old_price += +texture.price if old_price
				colorB.innerHTML = color.name + ' — ' + texture.name
			else
				colorB.innerHTML = color.name
		else
			colorP.style.display = 'none'
		if option
			optionP.style.display = 'block'
			price += +option.price
			old_price += +option.price if old_price
			optionB.innerHTML = option.name
		else
			optionP.style.display = 'none'
	else
		sizeP.style.display = colorP.style.display = optionP.style.display = 'none'
	summaryPrice.innerHTML = price.toCurrency()
	if old_price
		oldPrice.innerHTML = old_price.toCurrency()
		pricesDifference.innerHTML = (old_price - price).toCurrency()
	else
		oldPrice.parentNode.style.display = pricesDifference.parentNode.style.display = 'none'

@productPage = (p) ->
	p.price = +p.price
	p.old_price = +p.old_price if p.old_price
	product = p
	setSize 0
	refresh()

setActive = (wrap, el) ->
	if a = wrap.getElementsByClassName('checked')[0]
		a.className = 'i checkbox'
	el.getElementsByClassName('checkbox')[0].className = 'i checkbox checked'

setCur = (el, i) ->
	if cur = el.getElementsByClassName('cur')[0]
		cur.className = 'size'
	(el = el.children[i]).className = 'size cur'
	el

indexOf = (el) ->
	Array.prototype.indexOf.call el.parentNode.children, el

@sizeChoose = (el) ->
	setActive sizesTab, el
	setSize i = indexOf el
	if el = setCur(colorsTab, i).getElementsByClassName('checkbox')[0]
		el.className = 'i checkbox checked'
	if el = setCur(optionsTab, i).getElementsByClassName('checkbox')[0]
		el.className = 'i checkbox checked'
	refresh()

@chooseColor = (el) ->
	setActive colorsTab, el
	setColor indexOf el
	refresh()

@chooseTexture = (el) ->
	setActive colorsTab, el
	color = colors[indexOf el.parentNode.parentNode]
	setTexture indexOf el
	refresh()

@chooseOption = (el) ->
	setActive optionsTab, el
	setOption indexOf el
	refresh()