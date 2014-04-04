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
	count = 0
	cart.forEach (i) ->
		count += i.c
	$('#cartCount').html(count)
	if $('#cartfield')[0]
		$('#cartfield').val(JSON.stringify(cart))
	if $('#cart')[0]
		items = ''
		for item in cart
			if item.c > 1
				minus = '<span onclick="changeCount(this)">++</span>'
			else
				minus = '<span class="invis">++</span>'
			items += '<ul><li>'+item.n+'</li><li>'+minus+'<b>'+item.c+'</b>'+' <span onclick="changeCount(this)">+</span></li><li>'+item.p+' руб</li><li>'+item.s+'</li><li>'+item.l+'</li><li>'+item.o+'</li><li onclick="cartDelete(this)"></li></ul>'
		$('#cart div').html(items)
		window.changeCount = (el) ->
			ul = el.parentNode.parentNode
			name = ul.firstChild.innerHTML
			item = (cart.filter (item) ->
				item.n == name)[0]
			if el.innerHTML == '+'									
				item.c++
				if item.c > 1
					$(ul).find('.invis').attr('class', '').attr('onclick', 'changeCount(this)')
			else
				item.c--
				if item.c == 1
					$(ul).find('li span:first-child').attr('class', 'invis').attr('onclick', '')
			$(ul).find('b').html(item.c)
			document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()
		window.cartDelete = (el) ->
			name = el.parentNode.firstChild.innerHTML
			cart.splice cart.indexOf (cart.filter (item) ->
				item.n == name)[0], 1
			el.parentNode.outerHTML = ''
			document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()
	$(".accordion h3").click ->
		$(this).next(".panel").slideToggle("slow").siblings(".panel:visible").slideUp("slow");
		$(this).toggleClass("active");
		$(this).siblings("h3").removeClass("active");
	if $('.show')[0]
		window.currency = $('#price').html().split(' ')[1]
		window.priceNum = parseFloat $('#price').html()
		window.optionsPrice = ->
			price = 0
			$('select :selected').each ->
				price += parseFloat @.value
			price
		$('#price').html((priceNum+optionsPrice()).toFixed(2)+' '+currency)

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

window.addToCart = (name, price) ->	
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
	cart.forEach (i) ->
		count += i.c
		price += parseFloat(i.p)*i.c
	$('#cartCount').html(count)
	$('body').append('<div id="alert">\
			<div onclick="this.parentNode.parentNode.removeChild(this.parentNode)"></div>\
			<div style="top:'+($(window).height()/2-150)+'px; left:'+($(window).width()/2-200)+'px">\
				<div>\
					<div onclick="this.parentNode.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode.parentNode)">\
				</div>\
			</div>\
			<p>Товар "'+name+'" добавлен в <a href="/cart">корзину</a>.</p>\
			<p>В корзине '+count+', общая стоимость '+price+'</p>\
			<a class="continue" onclick="this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode)">Продолжить покупки</a>\
			</div>\
		</div>')
	$('#alert').fadeIn(300)
	cart.forEach (i) ->
		i.n = encodeURIComponent i.n
	document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toGMTString()
	cart.forEach (i) ->
		i.n = decodeURIComponent i.n

window.addImageUrl = (url) ->
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

window.deleteImage = (el) ->
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

window.priceChange = (el) ->
	$('#price').html((priceNum+optionsPrice()).toFixed(2)+' '+currency)#