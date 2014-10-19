# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_tree .
#= require tinymce-jquery

Number.prototype.toCurrency = ->
	(""+this.toFixed(2)).replace(/\B(?=(\d{3})+(?!\d))/g, " ")

iframe = document.createElement 'iframe'
menuImages = []

ready = ->
	$('#preloader').remove()
	configurator()
	curBg = 0
	$('#mainMenu li div div').each (i) ->
		this.style.backgroundImage = menuImages[i]
	$('#mainMenu li ul li').mouseover ->
		$(this).parents('li').find('div div').eq(curBg).css('left','-2000px')
		curBg = $(this).index()
		$(this).parents('li').find('div div').eq(curBg).css('left','0')
	$('#addImages input').click ->
		iframe.src = '/images/new'
		this.parentNode.appendChild iframe
	window.cart = eval getCookie 'cart'
	unless cart
		window.cart = []
	cartCount()
	$('#cartfield').val(JSON.stringify(cart))
	if $('#cart')[0]
		items = ''
		i = 0
		for item in cart
			if item.c > 1 then minus = '<span class="left" onclick="changeCount(this)">++</span>' else minus = '<span class="left invis">++</span>'
			if item.l then color = '<p>Цвет: '+item.l+'</p>' else color = ''
			if item.s then size = '<p>Размер: '+item.s+'</p>' else size = ''
			if item.o then option = '<p>Опции: '+item.o+'</p>' else option = ''
			items += '<div><span><div><div><p><ins><a href="/kupit/'+item.d+'">'+item.n+'</a></ins></p>'+size+color+option+'</div></div></span><div><p><b id="price">'+(parseFloat(item.p.replace(/\ /g, ''))*item.c).toCurrency()+'</b> руб.</p></div><div onselectstart="return false">'+minus+'<span id="count">'+item.c+'</span><span class="right" onclick="changeCount(this)">+</span></div><div onclick="cartDelete(this)"><span>+</span>Удалить</div></div>'
			$.ajax
				url: "/cart.json?name="+item.n
				success: (data) ->
					item = $($('#cart > div')[i++])
					window.item = item
					photoes = data.images.split(',')
					firstPhoto = photoes.shift()
					otherPhotoes = ''
					for img in photoes
						otherPhotoes += '<a href='+img+' data-lightbox="'+i+'"></a>'
					window.data = data
					item.find('span').first().prepend '<a href="'+firstPhoto+'" data-lightbox="'+i+'"><img src="'+firstPhoto+'"></a>'+otherPhotoes
		$('#cart').html(items)		
		window.cartDelete = (el) ->
			name = $(el.parentNode.parentNode).find('ins').html()
			cart.splice cart.indexOf (cart.filter (item) ->
				item.n == name)[0], 1
			el.parentNode.outerHTML = ''
			cartSave()
	$(".accordion h3").click ->
		$(this).next(".panel").slideToggle("slow").siblings(".panel:visible").slideUp("slow");
		$(this).toggleClass("active");
		$(this).siblings("h3").removeClass("active");
	if $('.show')[0]
		window.optionsPrice = (b) ->
			b = parseFloat b
			$('.option :checked').each ->
				b += parseFloat @.value
			b.toCurrency()
		$('#summaryPrice').html optionsPrice(priceNum)
	cartMenuGen()
	$(".sortable").sortable
		revert: true
		handle: '.handle'
		connectWith: ".sortable"
		update: ->
			id = $(this).parent().attr('id')
			if id
				parent_id = id.split('_')[1]
			else
				parent_id = 'nil'
			$.post '/categories/sort', $(this).sortable('serialize')+'&parent_id='+parent_id
	$('#productsSortable').sortable
		revert: true
		update: ->
			$.post '/products/sort', $(this).sortable 'serialize'
@changeCount = (el) ->
	window.el = el
	if el.parentNode.parentNode.parentNode.id == 'cart'
		div = el.parentNode.parentNode
		name = $(div).find('ins a').html()
	else
		div = el.parentNode.parentNode.parentNode.parentNode
		name = $(div).find('ins').html()
	item = (cart.filter (item) ->
		item.n == name)[0]
	if el.innerHTML == '+'								
		item.c++
		if item.c > 1
			$(div).find('.invis').attr('class', 'left').attr('onclick', 'changeCount(this)')
	else
		item.c--		
		if item.c == 1
			$(div).find('.left').attr('class', 'left invis').attr('onclick', '')
	$(div).find('#price').first().html (parseFloat(item.p.replace(/\ /g, ''))*item.c).toCurrency()
	$(div).find('#count').html(item.c)
	cartSave()
$(document).ready ->
	$('#mainMenu li div div').each ->
		menuImages.push this.style.backgroundImage
	ready()
$(document).on('page:load', ready)
getCookie = (name) ->
	matches = document.cookie.match(new RegExp("(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, "\\$1") + "=([^;]*)"))
	(if matches then decodeURIComponent(matches[1]) else `undefined`)
expire = ->
	new Date(new Date().setDate(new Date().getDate()+30))
@addToCartFromCatalog = (name, el) ->
	appear = $(el).parent()
	price = parseInt(appear.prev().find('.price').html().replace(' руб.', '').replace(/\ /g,'')).toCurrency()
	s = appear.find('.size').html()
	ss = appear.find('.size-scode').html()
	l = appear.find('.color').html()
	ls = appear.find('.color-scode').html()
	o = appear.find('.option').html()
	os = appear.find('.option-scode').html()
	i = appear.find('.id').html()
	d = appear.find('.scode').html()
	s = '' if !s
	l = '' if !l
	o = '' if !o
	ss = '' if !ss
	ls = '' if !ls
	os = '' if !os
	prev = (cart.filter (item) ->
		item.ss == ss and item.ls == ls and item.os == os and item.i == i and item.d == d)[0]
	if prev
		prev.c++
	else
		cart.push n: name, c: 1, p: price, s: s, l: l, o: o, i: i, d: d, ss: ss, ls: ls, os: os
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
			url: "/cart.json?name="+item.n
			success: (data) ->
				$('#alert .items > div').get().forEach (item) ->
					if $(item).find('ins').html() == data.name				
						$(item).find('img').attr 'src', data.images.split(',')[0]
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
@addToCart = (name, el) ->
	price = parseInt($(el).prev().find('b').html().replace(' руб.', '').replace(/\ /g,'')).toCurrency()
	s = $('[name=prsizes]:checked').next().html()
	ss = $('[name=prsizes]:checked').next().next().html()
	prcolor = $('[name=prcolors]:checked')
	if prcolor.next().length	
		l = $('[name=prcolors]:checked').next().val()
		ls = $('[name=prcolors]:checked').next().next().val()
	else
		l = prcolor.prev().prev().html()
		ls = prcolor.prev().prev().prev().html()
	o = $('[name=proptions]:checked').next().html()
	os = $('[name=proptions]:checked').next().next().html()
	i = $('#product_id_field').val()
	d = $('#product_scode').val()
	s = '' if !s
	l = '' if !l
	o = '' if !o
	prev = (cart.filter (item) ->
		item.ss == ss and item.ls == ls and item.os == os and item.i == i and item.d == d)[0]
	if prev
		prev.c++
	else
		cart.push n: name, c: 1, p: price, s: s, l: l, o: o, i: i, d: d, ss: ss, ls: ls, os: os
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
			url: "/cart.json?name="+item.n
			success: (data) ->
				$('#alert .items > div').get().forEach (item) ->
					if $(item).find('ins').html() == data.name				
						$(item).find('img').attr 'src', data.images.split(',')[0]
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
@cartMenuGen = ->
	items = ''
	allPrice = 0
	for item in cart
		if item.d and item.p and item.c and item.n
			if item.l then color = '<p>Цвет: '+item.l+'</p>' else color = ''
			if item.s then size = '<p>Размер: '+item.s+'</p>' else size = ''
			if item.o then option = '<p>Опции: '+item.o+'</p>' else option = ''
			items += '<a href="/kupit/'+item.d+'"><img><div><div><div>'+(parseFloat(item.p.replace(/\ /g, ''))*item.c).toCurrency()+' руб.</div><ins><span id="name">'+item.n+'</span> &#215;'+item.c+'</ins>'+color+size+option+'</div></div></a>'
			allPrice += parseFloat(item.p.replace(/\ /g, ''))*item.c
			$.ajax
				url: "/cart.json?name="+item.n
				success: (data) ->
					$('#menuCart > div > a').get().forEach (item) ->
						if $(item).find('#name').html() == data.name				
							$(item).find('img').attr 'src', data.images.split(',')[0]
	if items == ''
		$('#menuCart').hide()
	else $('#menuCart').show()
	$('#menuCart > div').html items
	$('#menuCart #price').html allPrice
@cartSave = ->
	cartCount()
	cartMenuGen()
	document.cookie = 'cart='+encodeURIComponent(JSON.stringify(cart))+';path=/;expires='+expire().toGMTString()
@addImageClick = (el) ->
	iframe.src = '/images/new'
	el.parentNode.appendChild iframe
@addImageUrl = (url) ->
	addImages = iframe.parentNode
	inputName = addImages.className
	input = $('#'+inputName)
	if input.attr('class') != 'one'
		images = input.val().split(',')
		if images[0] == '' then images = [url] else images.push url
		input.val(images.join(','))
		imagesHtml = ''
		for img in images
			imagesHtml += '<div><img class="img-thumbnail" src="'+img+'"><small class="btn btn-warning" onclick="deleteImage(this)">Удалить</small></div>'
		$(iframe.parentNode).find('div').html(imagesHtml)
	else
		input.val(url)
		if inputName == 'category_header'
			text = '<h4>Изображение в поле header</h4><div><div><img class="img-thumbnail" src="'+url+'"><small class="btn btn-warning" onclick="deleteImageHeader(this)">Удалить</small></div></div>'
		else
			window.el = addImages
			if $(el).prev().attr('class') != "btn btn-warning"
				$(el).before '<p class="btn btn-warning" onclick="imageChange(this)" data-url="'+url+'">Изменить</p>'
			else
				$(el).prev().html 'Изменить'
			text = '<img class="img-thumbnail" src="'+url+'"><div></div>'
		$(addImages).html text
	iframe.parentNode.removeChild iframe
@deleteImage = (el) ->
	div = el.parentNode
	input = $(div).parents('#addImages').next()
	$.get "/images/delete",
	  url: $(el).prev().attr 'src'
	index = $(div).parent().index div
	images = input.val().split ','
	images.splice index, 1
	input.val images.join ','
	div.parentNode.removeChild div
@deleteImageHeader = (el) ->
	$.get "/images/delete",
	  url: $(el).prev().attr 'src'
	$(el).parents('#addImages').html('<input onclick="addImageClick(this)" type="button" value="Добавить изображение в поле header" class="btn btn-primary"><div></div>').next().val('')
@priceChange = ->
	$('#summaryPrice').html optionsPrice(priceNum)
	productKeepPage()
@order = ->
	w = $('#orderWindow')
	d = w.find('>:last-child')
	w.fadeIn(300)
	if w
		w[0].parentNode.removeChild w[0]
		$('body')[0].appendChild(w[0])
		d.css 'left':$(window).width()/2-d.width()/2+'px', 'top':$(window).height()/2-d.height()/2-150+'px'
@orderShowAll = ->
	h = $($('#otherInputs')[0])
	if h.attr('class') == 'show'
		h.attr('class', '')
		h.animate 'height':'0px', 300
	else
		h.attr('class', 'show')
		h.animate 'height':'194px', 300
@cartCount = ->
	count = 0
	cart.forEach (i) ->
		count += i.c
	$('#cartCount').html(count) if count
@option = (el) ->
	next = $(el).next()
	if next.css('display') != 'none'
		next.hide 300, productKeepPage
	else
		$('.option').each ->
		next.show 300, productKeepPage
@addTexture = (el) ->
	div = $(el).next()
	window.div = div
	id = div.children().length + 1
	div.append('
	<div>
		<div style="margin-bottom:20px">
			<div class="row">
	      <h4 class="col-md-4 text-right"><label class="control-label wrath-content-box" for="textures__name">Название</label></h4>
	      <div class="col-md-4">
	        <div class="wrath-content-box">
	          <input class="form-control" id="textures__name" name="textures[][name]" type="text">
	        </div>
	      </div>
	    </div>
	    <div class="row">
	      <h4 class="col-md-4 text-right"><label class="control-label wrath-content-box" for="textures__scode">Код</label></h4>
	      <div class="col-md-4">
	        <div class="wrath-content-box">
	          <input class="form-control" id="textures__scode" name="textures[][scode]" type="text">
	        </div>
	      </div>
	    </div>
	    <div class="row">
	      <h4 class="col-md-4 text-right"><label class="control-label wrath-content-box" for="textures__price">Цена</label></h4>
	      <div class="col-md-4">
	        <div class="wrath-content-box">
	          <input class="form-control" id="textures__price" name="textures[][price]" type="text">
	        </div>
	      </div>
	    </div>
			<div id="addImages" class="textureImage'+id+'">
	      <input class="btn btn-primary" style="margin-top:10px" type="button" onclick="addImagesClick(this)" value="Добавить изображение">
	      <div></div>
	    </div>
			<input class="one" id="textureImage'+id+'" name="textures[][image]" type="hidden"><br>
			<p class="btn btn-danger" onclick="this.parentNode.parentNode.removeChild(this.parentNode)">Удалить текстуру</p>
		</div>
	</div>')    	
@addImagesClick = (el) ->
	iframe.src = '/images/new'
	el.parentNode.appendChild iframe
@showHideTextures = (el) ->
	el = $(el).parent().next()
	if el.css('display') == 'none'
		el.show(300)
	else
		el.hide(300)
@texturesWatch = (el) ->
	label = $(el).parent().next()
	if label.css('height') == '0px'
		label.animate 'height':Math.ceil(label.find('label').length/Math.floor(label.parent().width()/96))*131+'px', 300, productKeepPage
		el.innerHTML = 'Закрыть'
	else
		label.animate 'height':'0px', productKeepPage
		el.innerHTML = 'Посмотреть'
@imageChange = (el) ->
	if el.innerHTML == 'Изменить'
		el.innerHTML = 'Вернуть'
		$(el).next().html('<input class="btn btn-primary" style="margin-top:10px" type="button" onclick="addImagesClick(this)" value="Добавить изображение"><div></div>')
	else
		el.innerHTML = 'Изменить'
		$(el).next().html('<img src="'+$(el).data().url+'">').next().val($(el).data().url)
@photoLeft = (el) ->
	unless $(el).next().next().find('.showPhoto').attr('class','').prev().attr('class','showPhoto').prev()[0]
		$(el).attr 'class', 'left inactive'
		$(el).attr 'onclick', ''
	right = $(el).next()
	if right.attr('class') is 'right inactive'
		right.attr 'class', 'right'
		right.attr 'onclick', 'photoRight(this)'
@photoRight = (el) ->
	unless $(el).next().find('.showPhoto').attr('class','').next().attr('class','showPhoto').next()[0]
		$(el).attr 'class', 'right inactive'
		$(el).attr 'onclick', ''
	left = $(el).prev()
	if left.attr('class') is 'left inactive'
		left.attr 'class', 'left'
		left.attr 'onclick', 'photoLeft(this)'
@choosePhoto = (el) ->
	mini = $(el).parent()
	mini.find('.active').attr 'class',''
	$(el).attr 'class','active'
	photoes = mini.next()
	photoes.find('.showPhoto').attr 'class', ''
	$(photoes.children()[$(el).index()]).attr 'class', 'showPhoto'
@colorToggle = (el, action) ->
	unless el.className == 'btn btn-success'
		div = $(el).parent()
		colorFields = $(div).parents('.colorFields')
		div.find('> a').attr 'class', 'btn btn-default'
		colorFields.find('> span').hide()
		$(el).attr 'class', 'btn btn-success'
		colorFields.find('#'+action+'Color').show()
@showProductPrcolor = (el) ->
	if $(el).parent().attr('class') == 'active'
		$(el).parent().attr 'class', ''
		$(el).parent().next().hide(300)
	else
		$(el).parent().attr 'class', 'active'
		$(el).parent().next().show(300)
@copyPrcolorChoose = (el) ->
	window.el = el
	$('#copy_scode').val $(el).next().find('b').html()[1..-2]
@showHideProductsList = (el) ->
	products = $(el).parent().next()
	if products.css('display') == 'none'
		products.show 300
		$(el).html 'Спрятать'
	else
		products.hide 300
		$(el).html 'Показать'
orderItemPriceCalc = (el, num) ->
	tr = $(el).parents('tr')
	tr.find('.endPrice').html (parseInt(tr.find('.startPrice').html().replace(/\ /g, ''))*num).toCurrency()+' руб.'
@orderItemPlus = (el) ->
	$.post $(el).parent().data('url')+'/plus'
	prev = $(el).prev()
	num = parseInt(prev.html())+1
	prev.html num
	if num == 2
		prev.prev().attr 'class', 'btn btn-danger quantity'
	orderItemPriceCalc(el, num)
@orderItemMinus = (el) ->	
	next = $(el).next()
	num = parseInt(next.html())-1
	if num > 0
		$.post $(el).parent().data('url')+'/minus'
		next.html num
		$(el).attr 'class', 'btn btn-danger quantity'
	if num < 2
		$(el).attr 'class', 'btn btn-default quantity'
	orderItemPriceCalc(el, num)
validate = (input) ->
	if input.val() == ''
		input.parent().addClass 'has-error'
		input.attr 'placeholder','Заполните поле'
		false
	else
		input.parent().removeClass 'has-error'
		input.attr 'placeholder',''
		true
@orderValidate = (form) ->	
	ok = validate($(form).find('input:text').first())
	ok = validate($($(form).find('input:text')[1]))
	if ok
		document.cookie = 'cart='+encodeURIComponent(JSON.stringify(cart))+';path=/;expires=Thu, 01 Jan 1970 00:00:01 GMT'
	ok
@productValidate = ->
	ok = validate($('#product_name'))
	price = $('#product_price')
	if $('#product_price').val() <= 0
		ok = false
		price.parent().addClass 'has-error'
	else
		price.parent().removeClass 'has-error'
	ok
@categoryValidate = ->
	ok = true
	ok = validate($('#category_name'))
	ok
@windowClose = ->
	$('.windows').fadeOut(300)
@chooseCatParent = (el, id) ->
	treebox = $(el).parents('.treebox')
	treebox.find('p').first().html($(el).html())
	catDropDown(treebox.find('> p'))
	treebox.find('input').val(id)
@catDropDown = (el) ->
	parent = $(el).parent()
	div = parent.find('> div')
	unless div.is(':visible')
		$('#windowLayoutTransparent').show()
		div.show()
		parent.addClass 'active'
	else
		windowClose()
		parent.removeClass 'active'
@windowClose = ->
	$('.windows').fadeOut(300)
@orderEditSum = (el) ->
	main = $(el).parents(".main")
	pre = parseFloat main.find("#order_prepayment_sum").val()
	dop = parseFloat main.find("#order_doppayment_sum").val()
	final = parseFloat main.find("#order_finalpayment_sum").val()
	deliver = parseFloat main.find("#order_deliver_cost").val()
	p = parseFloat(main.find(".p").html())
	sum = main.find(".sum")
	dolg = main.find(".dolg")
	if !isNaN deliver
		price = (p + deliver).toFixed(2) 
		sum.html price + " руб."
	else
		price = p.toFixed(2)
		sum.html price + " руб."
	payed = 0
	for pay in [pre, dop, final]
		if !isNaN pay
			payed += pay
	dolg.html (price - payed).toFixed(2) + ' руб.'
@orderItemDiscountSave = (el, id) ->
	val = $(el).val()
	unless isNaN(val) and val != ''
		$.post '/orders/discount_save', p: val, id: id
@addVirtproduct = (el) ->
	$(el).parents('tr').before "<tr>
			<td><input type='text' name='text' class='form-control form-control-90'></td>
			<td><input type='text' name='price' class='form-control form-control-90'></td>
			<td><div class='btn btn-success' onclick='saveVirtProduct(this)'>Сохранить</div> <div class='btn btn-warning' onclick=\"$(this).parents('tr').remove()\">Отменить</div></td>
		<tr>"
@userSetRole = (el) ->
	params = {admin: false, manager: false, id: $(el).attr('name')}
	role = $(el).data('role')
	params.admin = true if role is 'admin'
	params.manager = true if role is 'manager'
	$.post '/users/role', params
@userConfirm = (el) ->
	tr = $(el).parents('tr')
	id = tr.data('id')
	$(el).parents('tr').html "<td><input type=\"text\" class=\"form-control\" value=\"#{tr.find('.form-control').val()}\" onchange=\"userSetPrefix(this)\"></td>
		<td>#{$(el).parent().prev().html()}</td>
		<td><input type=\"radio\" name=\"#{id}\" onchange=\"userSetRole(this)\" data-role=\"admin\"></td>
		<td><input type=\"radio\" name=\"#{id}\" onchange=\"userSetRole(this)\" data-role=\"manager\"></td>
		<td><input type=\"radio\" name=\"#{id}\" onchange=\"userSetRole(this)\" data-role=\"user\" checked=\"true\"></td>"
	$.post '/users/confirm', id: id
@userSetPrefix = (el) ->
	$.post "/users/#{$(el).parents('tr').data('id')}/prefix", val: $(el).val()
@addUser = (el) ->
	now = new Date
	$(el).parents('tr').before "<tr><td><input type=\"text\" class=\"form-control create-prefix\"></td>
		<td><input type=\"text\" class=\"form-control create-email\"></td>
		<td><input type=\"radio\" name=\"#{now}\" class=\"create-admin\"></td>
		<td><input type=\"radio\" name=\"#{now}\" class=\"create-manager\"></td>
		<td><input type=\"radio\" name=\"#{now}\" class=\"create-user\" checked=\"true\"></td>
		<td><input type=\"password\" class=\"form-control create-password\" placeholder=\"Пароль\"></td>
		<td><div class=\"btn btn-success\" onclick=\"createUser(this)\">Сохранить</div></td></tr>"
@createUser = (el) ->
	tr = $(el).parents('tr')
	params = {admin: false, manager: false, password: tr.find('.create-password').val(), email: tr.find('.create-email').val(), prefix: tr.find('.create-prefix').val()}
	switch tr.find('input:checked').attr('class')
		when 'create-admin'
			params.admin = true
		when 'create-manager'
			params.manager = true
	$.post '/users/admin-create', params, (d) ->
		checked = ' checked="true"'
		tr.data('id', d).html "<td><input type=\"text\" class=\"form-control\" value=\"#{params.prefix}\" onchange=\"userSetPrefix(this)\"></td>
			<td>#{params.email}</td>
			<td><input type=\"radio\" name=\"#{d}\" onchange=\"userSetRole(this)\" data-role=\"admin\"#{checked if params.admin}></td>
			<td><input type=\"radio\" name=\"#{d}\" onchange=\"userSetRole(this)\" data-role=\"manager\"#{checked if params.manager}></td>
			<td><input type=\"radio\" name=\"#{d}\" onchange=\"userSetRole(this)\" data-role=\"user\"#{checked if !params.admin and !params.manager}></td>
			<td colspan=\"2\">#{"<a class=\"btn btn-info\" href=\"/users/#{d}/logs\">Логи</a>" if params.manager}
				<div class=\"btn btn-danger\" onclick=\"destroyUser(this)\">Удалить</div>
			</td>"
@destroyUser = (el) ->
	tr = $(el).parents('tr')
	$.post '/users/destroy', id: tr.data('id')
	tr.remove()
@saveVirtProduct = (el) ->
	tr = $(el).parents 'tr'
	text = tr.find('[name=text]').val()
	price = tr.find('[name=price]').val()
	if text != '' and price != '' and !isNaN price
		$.post '/orders/add_virtproduct', text: text, price: price, id: $('#order-id').html(), (d) ->
			tr.data('id', d).html "<td><input onkeyup='editVirtProduct(this)' name='text' type='text' value='#{text}' class='form-control form-control-90'></td>
				<td><input onkeyup='editVirtProduct(this)' name='price' type='text' value='#{price}' class='form-control form-control-90'></td>
				<td><div class='btn btn-danger' onclick='destroyVirtProduct(this)'>Удалить</div></td>"
@editVirtProduct = (el) ->
	$.post "/orders/edit_virtproduct_#{$(el).attr('name')}", id: $(el).parents('tr').data('id')	, val: $(el).val()
@destroyVirtProduct = (el) ->
	$.post "/orders/destroy_virtproduct", id: $(el).parents('tr').data('id')
@orderStatus = (el) ->
	$(el).toggleClass 'open'
@setOrderStatus = (el) ->
	$(el).parents('.setStatus').toggleClass 'open'
	tr = $(el).parents('tr')
	tr.find('.status').html $(el).html()
	$.post "/orders/#{tr.data('id')}/status", status_id: $(el).data('id')
productKeepPage = ->
	pc = $('.productContent')
	o = []
	pc.find('.option').each ->
		if $(@).is(':visible')
			o.push 1
		else
			o.push 0
	t = []
	pc.find('.textures').each ->
		t.push $(@).height()
	s = pc.find('[name=prsizes]:checked').attr('class').split('size-scode-')[1]
	c = pc.find('[name=prcolors]:checked')
	if c.length > 0
		c = c.attr('class')
		if /^color-scode-/.test(c)
			c = c.split('color-scode-')[1]
			tx = false
		else
			tx = c.split('texture-scode-')[1]
			c = false
	else
		c = tx = false
	op = pc.find('[name=proptions]:checked').attr('class')
	if op
		op = op.split('option-scode-')[1]
	else
		op = false
	document.cookie = 'productPage='+JSON.stringify([o, t, s, c, tx, op])+";path=/kupit/#{$('#product_scode').val()};expires="+expire().toGMTString()
@productPage = ->
	productPage = eval getCookie 'productPage'
	if productPage
		pc = $('.productContent')
		i = 0
		pc.find('.option').each ->
			if productPage[0][i] == 1
				$(@).show()
			i += 1
		i = 0
		pc.find('.textures').each ->
			$(@).css 'height', "#{productPage[1][i]}px"
			i += 1
		pc.find(".size-scode-#{productPage[2]}").prop 'checked', true
		pc.find(".color-scode-#{productPage[3]}").prop 'checked', true if productPage[3]
		pc.find(".texture-scode-#{productPage[4]}").prop 'checked', true if productPage[4]
		pc.find(".option-scode-#{productPage[5]}").prop 'checked', true if productPage[5]