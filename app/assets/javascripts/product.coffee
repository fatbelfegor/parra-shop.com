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
	if options = size.proptions
		option = options[i]
	else option = undefined

setTexture = (i) ->
	if textures = color.textures
		texture = textures[i]
	else texture = undefined

setColor = (i) ->
	if colors = size.prcolors
		color = colors[i]
		setTexture 0
	else color = texture = undefined

setSize = (i) ->
	if sizes = product.prsizes
		size = sizes[i]
		setColor 0
		setOption 0
		colorNav.style.display = colors and 'inline-block' or 'none'
		optionNav.style.display = options and 'inline-block' or 'none'
	else size = color = texture = option = undefined

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
	product.total = summaryPrice.innerHTML = price.toCurrency()
	if old_price
		oldPrice.innerHTML = old_price.toCurrency()
		pricesDifference.innerHTML = (old_price - price).toCurrency()
		saveProcent.innerHTML = "-#{Math.round 100 - 100 * price / old_price}%"
	else
		pricePanel.className = 'without-old'

@productPage = (p) ->
	if p.prsizes.length
		for s in p.prsizes
			if s.prcolors and s.prcolors.length
				for c in s.prcolors
					if c.textures and not c.textures.length
						delete c.textures
			else delete s.prcolors
			if s.proptions and not s.proptions.length
				delete s.proptions
	else delete p.prsizes
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

@buyProduct = ->
	add = i: product.id, d: product.scode, a: product.s_title, n: product.name, p: product.total
	if size
		add.s = size.name
		add.ss = size.scode
		if color
			if texture
				add.l = texture.name
				add.ls = texture.scode
			else
				add.l = color.name
				add.ls = color.scode
		else add.l = add.ls = ''
		if option
			add.o = option.name
			add.os = option.scode
		else add.o = add.os = ''
	else add.s = add.ss = add.l = add.ls = add.o = add.os = ''
	addToCart add