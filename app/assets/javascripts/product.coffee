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
	if size
		s = size.name
		ss = size.scode
		if color
			if texture
				l = texture.name
				ls = texture.scode
			else
				l = color.name
				ls = color.scode
		else l = ls = ''
		if option
			o = option.name
			os = option.scode
		else o = os = ''
	else s = ss = l = ls = o = os = ''
	i = product.id
	d = product.scode
	prev = (cart.filter (item) ->
		item.ss == ss and item.ls == ls and item.os == os and item.i == i and item.d == d)[0]
	if prev
		prev.c++
	else
		cart.push {n: product.name, c: 1, p: product.total, s, l, o, i, d, ss, ls, os}
	count = 0
	price = 0
	i = 0
	items = '<div class="items">'
	cart.forEach (item) ->
		count += item.c
		price += parseFloat(item.p.replace(/\ /g, ''))*item.c
		if item.c > 1 then minus = '<span class="left" onclick="changeCount(this)">++</span>' else minus = '<span class="left invis">++</span>'
		if item.l then color = '<p>Цвет: '+item.l+'</p>' else color = ''
		if item.s then size = '<p>Размер: '+item.s+'</p>' else size = ''
		if item.o then option = '<p>Опции: '+item.o+'</p>' else option = ''
		items += '<div><a href="/kupit/'+item.d+'"><img><div><div><p><ins>'+item.n+'</ins></p>'+color+size+option+'</div></div></a><div><div><p><b id="price">'+(parseFloat(item.p.replace(/\ /g, ''))*item.c).toCurrency()+'</b> руб.</p><div onselectstart="return false">'+minus+'<span id="count">'+item.c+'</span><span class="right" onclick="changeCount(this)">+</span></div></div></div></div>'
		$.ajax
			url: "/cart.json?id="+item.i
			success: (data) ->
				$('#alert .items > div').get().forEach (item) ->
					if $(item).find('ins').html() == data.name				
						$(item).find('img').attr 'src', data.images[0][0]
	$('body').append('<div id="alert">\
			<div onclick="this.parentNode.parentNode.removeChild(this.parentNode)"></div>\
			<div style="top:'+($(window).height()/2-300)+'px; left:'+($(window).width()/2-235)+'px">\
				<div class="header">\
					Спасибо. Товар добавлен в Вашу корзину.\
					<div onclick="this.parentNode.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode.parentNode)">\
				</div>\
			</div>\
			'+items+'</div><p class="itogo">Итого: <b>'+price.toCurrency()+'</b> руб.</p>\
			<a class="continue" onclick="this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode)">Продолжить покупки</a>\
			<a href="/cart" class="gotoCart">Перейти в корзину</a>\
			</div>\
		</div>')
	$('#alert').fadeIn(300)	
	cartSave()