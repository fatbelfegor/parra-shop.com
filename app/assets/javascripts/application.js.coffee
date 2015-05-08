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
#= require bootstrap.min
#= require jquery-ui-1.10.4.custom.min

Number.prototype.toCurrency = ->
	(""+this.toFixed(2)).replace(/\B(?=(\d{3})+(?!\d))/g, " ")
String.prototype.toNum = ->
	parseFloat @.replace(/\ /g,'')

iframe = document.createElement 'iframe'
menuImages = []

scrollFunc = ->
	unless window.productLoading
		products = $('#products')
		if products.length > 0
			win = $(this)
			if win.scrollTop() + win.height() > products.offset().top + products.height() - 300
				window.productLoading = true
				productLoad.limit = Math.floor(($('#products').width() + 50) / 350) * Math.ceil(($(window).height() + 10) / 460) * 2
				productLoad.offset = products.find('> div').length
				$.post '/catalog/products', productLoad, (d) ->
					html = ''
					for r in d
						p = r.product
						extension = r.extension
						html += "<div><div>"
						html += "<img class='extension-catalog' src='#{extension.image}'>" if extension
						images = r.images
						html += '<div class="left inactive"></div>'
						if images[1]
							html += '<div class="right" onclick="photoRight(this)"></div>' 
						else
							html += '<div class="right inactive"></div>'
						if images.length > 0
							html += "<div class=\"photoes\"><a class=\"showPhoto\" href=\"/kupit/#{p.scode}\" style=\"background-image: url('#{images[0]}')\"></a>"
							for i in images[1..-1]
								html += "<a href=\"/kupit/#{p.scode}\" style=\"background-image: url('#{i.url}')\"></a>"
							html += '</div>'
						html += "<div><h3><a href=\"/kupit/#{p.scode}\">#{p.name}</a></h3></div><div>#{p.title}</div><div class='shortdesk'>#{p.shortdesk}</div><div><b>Цена:</b> <span class=\"price\">#{parseFloat(p.price).toCurrency()} руб.</span></div><div class=\"appear\">"
						html += "<div><b>Размер:</b> <span class=\"size\">#{r.sizes[0].name}</span><span class=\"hidden size-scode\">#{r.sizes[0].scode}</span></div>" if r.sizes.length > 0
						if r.colors.length > 0
							if r.textures.length > 0
									html += "<div><b>Цвет:</b> <span class=\"color\">#{r.textures[0].name}</span><span class=\"hidden color-scode\">#{r.textures[0].scode}</span></div>"
								else
									html += "<div><b>Цвет:</b> <span class=\"color\">#{r.colors[0].name}</span><span class=\"hidden color-scode\">#{r.colors[0].scode}</span></div>"
						html += "<div><b>Опция:</b> <span class=\"option\">#{r.options[0].name}</span><span class=\"hidden option-scode\">#{r.options[0].scode}</span></div>" if r.options.length > 0
						html += "<div class=\"id hidden\">#{p.id}</div><div class=\"scode hidden\">#{p.scode}</div><div class=\"fancyButton\" onclick=\"addToCartFromCatalog('#{p.name}', this)\">Купить</div></div></div></div>"
					if $('#products').append(html).find('> div').length == 0
						$('#products').html('<p class="notFound">По Вашему запросу ничего не найдено, попробуйте его изменить.</p>')
					window.productLoading = false
window.productLoading = false

resizeFunc = ->
	if $(document).width() > 1000
		$('body').removeClass 'small-size'
	else
		$('body').addClass 'small-size'

ready = ->
	$('#preloader').remove()
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
			add = 0
			$('.option :checked').each ->
				add += parseFloat @.value
			old_price_tag = $('#oldPrice')
			old_price = parseFloat(old_price_tag.data('val')) + add
			old_price_tag.html old_price.toCurrency()
			$('#pricesDifference').html (old_price - b - add).toCurrency()
			(b + add).toCurrency()
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
	$('.productImages').sortable
		revert: true
		update: ->
			images = []
			el = $(@).sortable()
			el.find('img').each ->
				images.push $(@).attr 'src'
			el.parent().next().val images.join ','
	resizeFunc()
	scrollFunc()
	$('.main').scroll scrollFunc
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
$(window).resize resizeFunc
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
					if data
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
@priceChange = (prsize) ->
	if prsize
		prsize = $ prsize
		wrap = prsize.parents('.productContent').find('.prsize-wrap')
		wrap.find('> .active').removeClass 'active'
		wrap.find('> div').eq(prsize.index()).addClass('active').find('> div').each ->
			$(@).find(':radio').eq(0).prop 'checked', 'checked'
	$('#summaryPrice').html optionsPrice(priceNum)
	productKeepPage()
	writeChars()
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
	$('div.option').hide 300
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
	photoes = mini.parent().find('.photoes')
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
	$('#copy_size').val $(el).data('id')
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
orderEditPriceCalc = (count, el) ->
	td = el.parent()
	next = td.next()
	next.next().html (td.prev().html().toNum() * count * (1 - next.html().toNum() / 100)).toFixed(2) + ' руб.'
	orderItemPrice()
@orderEditMinus = (el) ->
	if $(el).hasClass 'btn-danger'
		span = $(el).next()
		count = span.html() - 1
		span.html count
		if count == 1
			$(el).removeClass('btn-danger').addClass('btn-default')
		orderEditPriceCalc count, span
@orderEditPlus = (el) ->
	span = $(el).prev()
	count = parseInt(span.html()) + 1
	span.html count
	span.prev().removeClass('btn-default').addClass('btn-danger')
	orderEditPriceCalc count, span
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
@orderEditSum = ->
	pre = $("#order_prepayment_sum").val().toNum()
	dop = $("#order_doppayment_sum").val().toNum()
	final = $("#order_finalpayment_sum").val().toNum()
	deliver = $("#order_deliver_cost").val().toNum()
	p = $(".p").html().toNum()
	sum = $(".sum")
	dolg = $(".dolg")
	if !isNaN deliver
		price = p + deliver
		sum.html price.toCurrency() + " руб."
	else
		sum.html p.toCurrency() + " руб."
	payed = 0
	for pay in [pre, dop, final]
		if !isNaN pay
			payed += pay
	dolg.html (price - payed).toCurrency() + ' руб.'
@orderItemDiscountSave = (el, id) ->
	val = $(el).val()
	unless isNaN(val) and val != ''
		$.post '/orders/discount_save', p: val, id: id
@addVirtproduct = (el) ->
	$(el).parents('tr').before "<tr>
			<td><input type='text' name='text' class='form-control form-control-90'></td>
			<td><input type='text' name='price' class='form-control form-control-90'></td>
			<td><div class='btn btn-success' onclick='saveVirtProduct(this)'>Сохранить</div> <div class='btn btn-warning' onclick=\"$(this).parents('tr').remove()\">Отменить</div></td>
		</tr>"
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
			tr.data('id', d)
			if $(el).data('edit')
				tds = tr.find 'td'
				tds.eq(1).attr 'onkeyup', 'editVirtProduct(this)'
				tds.eq(2).attr 'onkeyup', 'editVirtProduct(this)'
				tds.eq(3).html '<div class="btn btn-danger" onclick="destroyVirtProduct(this)">Удалить</div>'
				orderItemPrice()
			else
				tr.html "<td><input onkeyup='editVirtProduct(this)' name='text' type='text' value='#{text}' class='form-control form-control-90'></td>
					<td><input onkeyup='editVirtProduct(this)' name='price' type='text' value='#{price}' class='form-control form-control-90'></td>
					<td><div class='btn btn-danger' onclick='destroyVirtProduct(this)'>Удалить</div></td>"
@editVirtProduct = (el, price) ->
	$.post "/orders/edit_virtproduct_#{$(el).attr('name')}", id: $(el).parents('tr').data('id')	, val: $(el).val()
	orderItemPrice()
orderItemPrice = ->
	table = $('table.order-items')
	if table.length > 0
		price = 0
		count = 0
		table.find('tr').each ->
			td = $(@).find('td')
			if $(@).hasClass 'order-item'
				item = $(@).find('.item-price')
				if item.length > 0
					price += item.html().toNum()
				else
					price += $(@).find('[name=price]').val().toNum()
				span = $(@).find 'span'
				if span.length > 0
					count += parseInt span.html()
				else
					count += 1
			else
				p = $(@).find('.p')
				if p.length > 0
					p.html price.toFixed(2) + ' руб.'
					p.prev().prev().html count
		orderEditSum()
@destroyVirtProduct = (el) ->
	table = $(el).parents('table')
	tr = $(el).parents('tr')
	$.post "/orders/destroy_virtproduct", id: tr.data('id'), ->
		tr.remove()
		i = 0
		table.find('tr').each ->
			tds = $(@).find 'td'
			if tds.length > 0
				tds.first().html i += 1
		orderItemPrice()
@orderAddVirt = (el) ->
	$(el).parents('tr').before "<tr class='order-item'>
			<td>#{$(el).parents('table').find('tr').length - 5}</td>
			<td colspan=\"3\"><input type='text' name='text' class='form-control form-control-90'></td>
			<td colspan=\"2\"><input type='text' name='price' class='form-control form-control-90'></td>
			<td><div class='btn btn-success' data-edit='true' onclick='saveVirtProduct(this)'>Сохранить</div></td>
		</tr>"
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
	s = pc.find('[name=prsizes]:checked').attr('class')
	if s
		s = s.split('size-scode-')[1]
	else
		s = false
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
		pc.find(".size-scode-#{productPage[2]}").prop 'checked', true if productPage[2]
		pc.find(".color-scode-#{productPage[3]}").prop 'checked', true if productPage[3]
		pc.find(".texture-scode-#{productPage[4]}").prop 'checked', true if productPage[4]
		pc.find(".option-scode-#{productPage[5]}").prop 'checked', true if productPage[5]
	writeChars()
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
	console.log 'qwe'
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
@miniCatOpen = (el) ->
	cat = $(el)
	if cat.hasClass 'open'
		cat.removeClass 'open'
		cat.find('a').animate 'height': '0', 500
	else
		cat.parent().find('.open').removeClass('open').find('a').animate 'height': '0', 500
		cat.addClass 'open'
		height = (cat.find('img').first().height() + 3) + 'px'
		cat.find('a').animate 'height': height, 500
writeChars = ->
	prsizes = $('[name=prsizes]:checked')
	prcolors = $('[name=prcolors]:checked')
	proptions = $('[name=proptions]:checked').next().html()
	chars = $('#choosedChars')
	show = false
	if prsizes[0]
		show = true
		chars.find('.size').show().find('b').html prsizes.parent().find('span').first().html()
	else
		chars.find('.size').hide()
	if prcolors[0]
		show = true
		color = prcolors.parent().data 'color'
		if color
			chars.find('.color').show().find('b').html color
		else
			chars.find('.color').show().find('b').html "#{prcolors.parents('.catalog').find('p')[1].innerHTML} — #{prcolors.parent().find('p')[1].innerHTML}"
	else
		chars.find('.color').hide()
	if proptions != 'Без опций'
		show = true
		chars.find('.opt').show().find('b').html proptions
	else
		chars.find('.opt').hide()
	if show
		$('#choosedChars').show()
	else
		$('#choosedChars').hide()
@addSubCatImage = (el) ->
	$(el).next().append "<tr><td>
			<span style='float: right' class='btn btn-danger' onclick='$(this).parents(\"tr\").eq(0).remove()'>Удалить изображение</span>
			<input type='file' name='images[]file'>
			<p>Описание: </p>
			<textarea class='tinymce' name='images[]description'></textarea>
			<input hidden='images[]id'>
			<input hidden='images[]destroy'>
		</td></tr>"
	tinyMCE.init
		selector: "textarea.tinymce"
		theme_advanced_toolbar_location: "top"
		theme_advanced_toolbar_align: "left"
		theme_advanced_statusbar_location: "bottom"
		theme_advanced_buttons3_add: ["tablecontrols","fullscreen"]
		plugins: "table,fullscreen,code"
@copyCatProducts = (el, cat, from) ->
	$(el).parents('.treebox').removeClass('active')
	$.post '/categories/copy', cat: cat, from: from, ->
		location.reload()
@subCatSubmit = (el) ->
	$(el).find('[type=file]').each ->
		el = $ @
		el.after "<input type='hidden' name='images[]file'>" if el.val() is ''
@sizeOpen = (el) ->
	el = $(el)
	if el.html() is 'Развернуть'
		el.html 'Свернуть'
	else
		el.html 'Развернуть'
	el.parents('tr').next().toggleClass('show').next().toggleClass('show')
@sizeSubOpen = (el) ->
	el = $(el)
	if el.html() is 'Развернуть'
		el.html 'Свернуть'
	else
		el.html 'Развернуть'
	el.parents('table').eq(0).toggleClass('hide')
@colorOpen = (el) ->
	el = $(el)
	if el.html() is 'Развернуть'
		el.html 'Свернуть'
	else
		el.html 'Развернуть'
	el.parents('tr').next().toggleClass('show')