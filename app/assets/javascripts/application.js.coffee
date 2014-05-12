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
#= require tinymce

Number.prototype.toCurrency = ->
	(""+this.toFixed(2)).replace(/\B(?=(\d{3})+(?!\d))/g, " ")

iframe = document.createElement 'iframe'
menuImages = []

ready = ->
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
	if $('#cartfield')[0]
		$('#cartfield').val(JSON.stringify(cart))
	if $('#cart')[0]
		items = ''
		i = 0
		for item in cart
			if item.c > 1 then minus = '<span class="left" onclick="changeCount(this)">++</span>' else minus = '<span class="left invis">++</span>'
			if item.l then color = '<p>Цвет: '+item.l+'</p>' else color = ''
			if item.s then size = '<p>Размер: '+item.s+'</p>' else size = ''
			if item.o then option = '<p>Опции: '+item.o+'</p>' else option = ''
			items += '<div><span><img><div><div><p><ins><a href="/kupit/'+item.d+'">'+item.n+'</a></ins></p>'+size+color+option+'</div></div></span><div><p><b id="price">'+(parseFloat(item.p.replace(/\ /g, ''))*item.c).toCurrency()+'</b> руб.</p></div><div onselectstart="return false">'+minus+'<span id="count">'+item.c+'</span><span class="right" onclick="changeCount(this)">+</span></div><div onclick="cartDelete(this)"><span>+</span>Удалить</div></div>'
			$.ajax
				url: "/cart.json?name="+item.n
				success: (data) ->
					item = $($('#cart > div')[i++])
					item.find('img').attr 'src', data.images.split(',')[0]
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
			b = parseInt b
			$('.option :checked').each ->
				b += parseInt @.value
			b.toCurrency()
		$('#summaryPrice').html(optionsPrice(priceNum[0])+' '+priceNum[1])
	cartMenuGen()
@changeCount = (el) ->
	if el.parentNode.parentNode.parentNode.id == 'cart'
		div = el.parentNode.parentNode
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
	l = appear.find('.color').html()
	o = appear.find('.option').html()
	i = appear.find('.id').html()
	d = appear.find('.scode').html()
	s = '' if !s
	l = '' if !l
	o = '' if !o
	prev = (cart.filter (item) ->
		item.s == s and item.l == l and item.o == o and item.i == i and item.d == d)[0]
	if prev
		prev.c++
	else
		cart.push n: name, c: 1, p: price, s: s, l: l, o: o, i: i, d: d
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
	prcolor = $('[name=prcolors]:checked')
	if prcolor.next().length	
		l = $('[name=prcolors]:checked').next().val()
	else
		l = prcolor.prev().prev().html()
	o = $('[name=proptions]:checked').next().html()
	i = $('#product_id_field').val()
	d = $('#product_scode').val()
	s = '' if !s
	l = '' if !l
	o = '' if !o
	prev = (cart.filter (item) ->
		item.s == s and item.l == l and item.o == o and item.i == i and item.d == d)[0]
	if prev
		prev.c++
	else
		cart.push n: name, c: 1, p: price, s: s, l: l, o: o, i: i, d: d
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
	cart.forEach (i) ->
		i.n = encodeURIComponent i.n
	document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toGMTString()
	cart.forEach (i) ->
		i.n = decodeURIComponent i.n
@addImageUrl = (url) ->
	inputName = iframe.parentNode.className
	input = $('#'+inputName)
	if inputName == "product_images"
		images = input.val().split(',')
		if images[0] == '' then images = [url] else images.push url
		input.val(images.join(','))
		imagesHtml = ''
		for img in images
			imagesHtml += '<img src="'+img+'">'
		$(iframe.parentNode).find('div').html(imagesHtml)
	else
		input.val(url)
		$(iframe.parentNode).html(imagesHtml = '<img src="'+url+'">')
	iframe.parentNode.removeChild iframe
@deleteImage = (el) ->
	li = el.parentNode
	url = li.firstElementChild.href
	$.get "/images/delete",
	  url: url
	li.parentNode.removeChild li
	index = $('.images li').index li
	images = $('#product_images').val().split ','
	images.splice index, 1
	$('#product_images').val images.join ','
	index = $('.images li').index(li)
	images = $('#product_images').val().split(',')
	$('#product_images').val(images.join(','))
@priceChange = ->
	$('#summaryPrice').html(optionsPrice(priceNum[0])+' '+priceNum[1])
@order = ->
	w = $('#orderWindow')
	d = w.find('>:last-child')
	w.fadeIn(300)
	if w
		w[0].parentNode.removeChild w[0]
		$('body')[0].appendChild(w[0])
		d.css 'left':$(window).width()/2-d.width()/2+'px', 'top':$(window).height()/2-d.height()/2-150+'px'
@orderShowAll = ->
	h = $('#otherInputs')[0]
	if h.className == 'hide'
		h.className = ''
	else
		h.className = 'hide'
@cartCount = ->
	count = 0
	cart.forEach (i) ->
		count += i.c
	$('#cartCount').html(count) if count
@option = (el) ->
	next = $(el).next()
	if next.css('display') != 'none'
		next.hide(300)
	else
		$('.option').each ->
			if $(this).css('display') != 'none'
				$(this).hide(300)
		next.show(300)
@addTexture = (el) ->
	div = $(el).next()
	window.div = div
	id = div.children().length + 1
	div.append('
	<div>
		<label for="textures__name">Название</label><br>
		<input id="textures__name" name="textures[][name]" type="text"><br>
		<label for="textures__scode">Код</label><br>
		<input id="textures__scode" name="textures[][scode]" type="text"><br>
		<label for="textures__price">Цена</label><br>
		<input id="textures__price" name="textures[][price]" type="text"><br>
		<label for="textures__image">Изображение</label><br>
		<div id="addImages" class="textureImage'+id+'">
			<input type="button" onclick="addImagesClick(this)" value="Добавить изображение">
		</div>
		<input id="textureImage'+id+'" name="textures[][image]" type="hidden" value=""><br>
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
		label.animate 'height':Math.ceil(label.find('label').length/Math.floor(label.parent().width()/96))*131+'px', 300
		el.innerHTML = 'Закрыть'
	else
		label.animate 'height':'0px'
		el.innerHTML = 'Посмотреть'
@imageChange = (el) ->
	if el.innerHTML == 'Изменить'
		el.innerHTML = 'Вернуть'
		$(el).next().html('<input type="button" onclick="addImagesClick(this)" value="Добавить изображение">')
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