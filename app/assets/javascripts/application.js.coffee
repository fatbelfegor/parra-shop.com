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
#= require ckeditor/override
#= require ckeditor/init

iframe = document.createElement 'iframe'
images = []

ready = ->
	console.log 'asd'
	curBg = 0
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
		count += i.count
	$('#cartCount').html(count)
	if $('#cart')
		items = ''
		for item in cart
			if item.count > 1
				minus = '<span onclick="changeCount(this)">++</span>'
			else
				minus = '<span class="invis">++</span>'
			items += '<ul><li>'+item.name+'</li><li>'+minus+'<b>'+item.count+'</b>'+' <span onclick="changeCount(this)">+</span></li><li>'+item.price+' руб</li><li>'+item.s+'</li><li>'+item.c+'</li><li>'+item.o+'</li><li onclick="cartDelete(this)"></li></ul>'
		$('#cart div').html(items)
		window.changeCount = (el) ->
			ul = el.parentNode.parentNode
			name = ul.firstChild.innerHTML
			item = (cart.filter (item) ->
				item.name == name)[0]
			if el.innerHTML == '+'									
				item.count++
				if item.count > 1
					$(ul).find('.invis').attr('class', '').attr('onclick', 'changeCount(this)')
			else
				item.count--
				if item.count == 1
					$(ul).find('li span:first-child').attr('class', 'invis').attr('onclick', '')
			$(ul).find('b').html(item.count)
			document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()
		window.cartDelete = (el) ->
			name = el.parentNode.firstChild.innerHTML
			cart.splice cart.indexOf (cart.filter (item) ->
				item.name == name)[0], 1
			el.parentNode.outerHTML = ''
			document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()

$(document).ready(ready)
$(document).on('page:load', ready)

getCookie = (name) ->
	matches = document.cookie.match(new RegExp("(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, "\\$1") + "=([^;]*)"))
	(if matches then decodeURIComponent(matches[1]) else `undefined`)

expire = ->
	new Date(new Date().setDate(new Date().getDate()+30))

window.addToCart = (name, price) ->
	if $('#alert').get().length == 0
		$('body').append('<div id="alert"><div onclick="$(this.parentNode).fadeOut(300)"></div><div style="top:'+($(window).height()/2-150)+'px; left:'+($(window).width()/2-200)+'px"><div><div onclick="$(this.parentNode.parentNode.parentNode).fadeOut(300)"></div></div><p>Товар "'+name+'" добавлен в <a href="/cart">корзину</a>.</p><a class="continue" onclick="$(this.parentNode.parentNode).fadeOut(300)">Продолжить покупки</a></div></div>')
	$('#alert').fadeIn(300)
	s = $('[name=prsizes] :selected').html()
	c = $('[name=prcolors] :selected').html()
	o = $('[name=proptions] :selected').html()
	prev = (cart.filter (item) ->
		item.name == name and item.s == s and item.c == c and item.o == o)[0]
	if prev
		prev.count++
	else
		cart.push name: name, count: 1, price: price, s: s, c: c, o: o
	count = 0
	cart.forEach (i) ->
		count += i.count
	$('#cartCount').html(count)
	document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()

window.addImageUrl = (url) ->
	iframe.parentNode.removeChild iframe
	images.push url
	imagesHtml = ''
	$('#product_images').val(images.join(','))
	for img in images
		imagesHtml += '<img src="'+img+'">'
	$('#addImages div').html(imagesHtml)