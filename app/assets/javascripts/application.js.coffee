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
			items += '<div><a href="/kupit/'+item.n+'"><img><div><div><p><ins>'+item.n+'</ins></p><p>Код: <s id="scode"></s></p>'+color+size+option+'</div></div></a><div><p><b id="price">'+item.p*item.c+'</b> руб.</p></div><div onselectstart="return false">'+minus+'<span id="count">'+item.c+'</span><span class="right" onclick="changeCount(this)">+</span></div><div onclick="cartDelete(this)"><span>+</span>Удалить</div></div>'
			$.ajax
				url: "/cart.json?name="+item.n
				success: (data) ->
					item = $($('#cart > div')[i++])
					item.find('img').attr 'src', data.images.split(',')[0]
					item.find('#scode').html data.scode
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
		price = $('#price').html().split(' ')
		window.optionsPrice = ->
			p = 0
			$('select :selected').each ->
				p += @.value
			if p then p else ''
		$('#price').html(price[0]+optionsPrice()+' '+price[1])
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
	$(div).find('#price').first().html item.p * item.c
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
@addToCart = (name, price) ->	
	s = $('[name=prsizes] :selected').html()
	l = $('[name=prcolors] :selected').html()
	o = $('[name=proptions] :selected').html()
	i = $('#product_id_field').val()
	s = '' if !s
	l = '' if !l
	o = '' if !o
	prev = (cart.filter (item) ->
		item.s == s and item.l == l and item.o == o and item.i == i)[0]
	if prev
		prev.c++
	else
		cart.push n: name, c: 1, p: price, s: s, l: l, o: o, i: i
	count = 0
	price = 0
	i = 0
	items = '<div class="items">'
	cart.forEach (item) ->
		count += item.c
		price += parseFloat(item.p)*item.c
		if item.c > 1 then minus = '<span class="left" onclick="changeCount(this)">++</span>' else minus = '<span class="left invis">++</span>'
		if item.l then color = '<p>Цвет: '+item.l+'</p>' else color = ''
		if item.s then size = '<p>Размер: '+item.s+'</p>' else size = ''
		if item.o then option = '<p>Опции: '+item.o+'</p>' else option = ''
		items += '<div><a href="/kupit/'+item.n+'"><img><div><div><p><ins>'+item.n+'</ins></p><p>Код: <s id="scode"></s></p>'+color+size+option+'</div></div></a><div><div><p><b id="price">'+item.p*item.c+'</b> руб.</p><div onselectstart="return false">'+minus+'<span id="count">'+item.c+'</span><span class="right" onclick="changeCount(this)">+</span></div></div></div></div>'
		$.ajax
			url: "/cart.json?name="+item.n
			success: (data) ->
				item = $($('#alert .items > div')[i++])
				item.find('img').attr 'src', data.images.split(',')[0]
				item.find('#scode').html data.scode
	$('body').append('<div id="alert">\
			<div onclick="this.parentNode.parentNode.removeChild(this.parentNode)"></div>\
			<div style="top:'+($(window).height()/2-230)+'px; left:'+($(window).width()/2-235)+'px">\
				<div class="header">\
					Спасибо. Товар добавлен в Вашу корзину.\
					<div onclick="this.parentNode.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode.parentNode)">\
				</div>\
			</div>\
			'+items+'</div><p class="itogo">Итого: <b>'+price+'</b> руб.</p>\
			<a class="continue" onclick="this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode)">Продолжить покупки</a>\
			<a href="/cart" class="gotoCart">Перейти в корзину</a>\
			</div>\
		</div>')
	$('#alert').fadeIn(300)	
	cartSave()
@cartSave = ->
	cartCount()
	cart.forEach (i) ->
		i.n = encodeURIComponent i.n
	document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toGMTString()
	cart.forEach (i) ->
		i.n = decodeURIComponent i.n
@addImageUrl = (url) ->
	inputName = iframe.parentNode.className
	input = $('#'+inputName)
	images = input.val().split(',')
	if images[0] == ''
		images = []
	images.push url
	imagesHtml = ''
	input.val(images.join(','))	
	for img in images
		imagesHtml += '<img src="'+img+'">'
	if inputName == "product_images"
		$(iframe.parentNode).find('div').html(imagesHtml)
	else
		$(iframe.parentNode).html(imagesHtml)
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
@priceChange = (el) ->
	$('#price').html(priceNum+optionsPrice()+' '+currency)
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