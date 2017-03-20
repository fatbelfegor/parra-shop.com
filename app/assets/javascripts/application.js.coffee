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
#= require bootstrap.min
#= require jquery-ui-1.10.4.custom.min
#= require tinymce-jquery
#= require polyfills

Number.prototype.toCurrency = ->
	(""+this.toFixed(2)).replace(/\B(?=(\d{3})+(?!\d))/g, " ")
String.prototype.toNum = ->
	parseFloat @.replace(/\ /g,'')

iframe = document.createElement 'iframe'
menuImages = []

ready = ->

	header.onmouseover = (e) ->
		el = e.target
		if el.className is 'bg'
			list = el.parentNode
			background = list.previousElementSibling
			if active = background.getElementsByClassName('active')[0]
				active.className = ''
			background.children[Array.prototype.indexOf.call list.children, el].className = 'active'

	if products = document.getElementById 'products'
		for div in products.children
			div.style.height = div.firstElementChild.offsetHeight + 'px'

	$('#addImages input').click ->
		iframe.src = '/images/new'
		this.parentNode.appendChild iframe
	cart = eval getCookie 'cart'
	window.cart = []
	if cart
		for item in cart
			if item.c and item.i and item.p
				window.cart.push item
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
			id = item.i
			items += '<div data-id="' + id + '" data-ls="' + item.ls + '" data-os="' + item.os + '" data-ss="' + item.ss+ '"><span><div><div><p><ins><a href="/kupit/'+item.d+'">'+item.n+'</a></ins></p>'+size+color+option+'</div></div></span><div><p><b id="price">'+(parseFloat(item.p.replace(/\ /g, ''))*item.c).toCurrency()+'</b> руб.</p></div><div onselectstart="return false">'+minus+'<span id="count">'+item.c+'</span><span class="right" onclick="changeCount(this)">+</span></div><div onclick="cartDelete(this)"><span>+</span>Удалить</div></div>'
			((id) ->
				$.ajax
					url: "/cart.json?id="+item.i
					success: (data) ->
						item = $("#cart > [data-id='#{id}']")
						if photoes = data.images
							firstPhoto = photoes.shift()
							otherPhotoes = ''
							for img in photoes
								otherPhotoes += '<a href='+img[0]+' data-lightbox="'+i+'"></a>'
							item.find('span').first().prepend '<a href="'+firstPhoto[0]+'" data-lightbox="'+i+'"><img src="'+firstPhoto[1]+'"></a>'+otherPhotoes
			)(id)
		$('#cart').html(items)		
	$(".accordion h3").click ->
		$(this).next(".panel").slideToggle("slow").siblings(".panel:visible").slideUp("slow");
		$(this).toggleClass("active");
		$(this).siblings("h3").removeClass("active");
	if $('.show')[0]
		window.optionsPrice = (b) ->
			b = parseFloat b
			add = 0
			old = 0
			$('.option :checked').each ->
				float = parseFloat @.value
				add += float
				old_price = parseFloat $(@).data 'oldPrice'
				if old_price
					old += old_price
				else old += float
			res_price = b + add
			old_price_tag = $('#oldPrice')
			old_product_price = parseFloat(old_price_tag.data('val')) || b
			res_old_price = old_product_price + old
			if res_old_price isnt res_price
				old_price = res_old_price
				old_price_tag.html old_price.toCurrency()
				$('#pricesDifference').html (old_price - res_price).toCurrency()
				$('p.old_price').show()
				$('p.difference').show()
			else
				$('p.old_price').hide()
				$('p.difference').hide()
			$('#pricesDifference').html (old_price - b - add).toCurrency()
			res_price.toCurrency()
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
		items: "> div"
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

@cartDelete = (el) ->
	wrap = el.parentNode
	id = wrap.dataset.id
	ls = wrap.dataset.ls
	os = wrap.dataset.os
	ss = wrap.dataset.ss
	cart.splice cart.indexOf (cart.find (item) ->
		item.ss == ss and item.ls == ls and item.os == os and item.i == id)[0], 1
	wrap.outerHTML = ''
	cartSave()

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
	total = 0
	for item in cart
		total += +item.c * +item.p.replace(/\s/g, '')
	$(div.parentNode.parentNode).find('.itogo b').html(total.toCurrency())
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

@closeCartPopup = ->
	popupContainer.parentNode.removeChild(popupContainer)
	document.body.style.overflow = 'auto'

@addToCart = (add) ->
	for item in cart
		if item.ss == add.ss and item.ls == add.ls and item.os == add.os and item.i == add.i and item.d == add.d
			prev = item
	if prev
		prev.c++
	else
		add.c = 1
		cart.push add
	total = 0
	res = """
		<div id='popupContainer' onclick='closeCartPopup()'>
			<div id='popupCart' onclick='event.stopPropagation()'>
				<div class='close' onclick='closeCartPopup()'>✖</div>
				<div class='title'>Спасибо! Товар добавлен в корзину.</div>
				<div id='cartList' class='list'>"""
	for item, i in cart
		do (index = i) ->
			price = item.c * (p = parseFloat item.p.replace /\ /g, '')
			total += price
			res += """<div class='item' data-i='#{i}' data-price='#{p}'><img>
					<div class='text'>
						<a href='/kupit/#{item.d}'>#{item.n}</a>
						<p>Артикул: #{item.a}</p>"""
			res += "<p>Размер: #{item.s}</p>" if item.s
			res += "<p>Цвет: #{item.l}</p>" if item.l
			res += "<p>Опции: #{item.o}</p>" if item.o
			res += """</div>
				<div class='counter'>
					<div class='minus' onclick='cartMinus(this)'>−</div>
					<div class='count'>#{item.c}</div>
					<div class='plus' onclick='cartPlus(this)'>+</div>
					<img onclick='cartDelete(this)' src='/assets/icon/delete.png' class='delete'>
				</div>
				<div class='price'><span class='price-value'>#{price.toCurrency()}</span> <img src="/assets/icon/rubl.png"></div>
			</div>"""
			x = new XMLHttpRequest
			x.open 'GET', "/cart.json?id=#{item.i}"
			x.setRequestHeader "Content-Type", "application/json"
			x.onload = ->
				cartList.children[index].firstChild.src = JSON.parse(@response).images[0][1]
			x.send()
	res += """</div>
			<div class='total'>
				Итого: <span class='total-value'>#{total.toCurrency()}</span> <img src="/assets/icon/rubl.png">
			</div>
			<div class='buttons'>
				<div onclick='closeCartPopup()' class='btn white'>Продолжить покупки</div>
				<a href='/cart' class='btn green'>Оформить заказ</a>
			</div>
		</div>
	</div>"""
	document.body.insertAdjacentHTML 'beforeend', res
	document.body.style.overflow = 'hidden'
	popupContainer.style.display = 'flex'
	getComputedStyle(popupContainer).top
	popupContainer.className = 'active'
	cartSave()

@addToCartFromCatalog = (el) ->
	el = el.parentNode.parentNode
	add =
		i: +el.getElementsByClassName('id')[0].textContent
		d: el.getElementsByClassName('scode')[0].textContent
		a: el.getElementsByClassName('articul')[0].textContent
		n: el.getElementsByClassName('product-name')[0].textContent
		p: el.getElementsByClassName('price')[0].textContent.replace(' руб.', '')
		s: ''
		l: ''
		o: ''
		ss: ''
		ls: ''
		os: ''
	if a = el.getElementsByClassName('size')[0]
		add.s = a.textContent
		add.ss = a.nextElementSibling.textContent
	if a = el.getElementsByClassName('color')[0]
		add.l = a.textContent
		add.ls = a.nextElementSibling.textContent
	if a = el.getElementsByClassName('option')[0]
		add.o = a.textContent
		add.os = a.nextElementSibling.textContent
	addToCart add

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
				url: "/cart.json?id="+item.i
				success: (data) ->
					if data
						$('#menuCart .cart-list > a').get().forEach (item) ->
							if $(item).find('#name').html() == data.name				
								$(item).find('img').attr 'src', data.images[0][1]
	if items == ''
		$('#menuCart').hide()
	else $('#menuCart').show()
	$('#menuCart .cart-list').html items
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
	$div = $ div
	input = $div.parents('#addImages').next()
	$.get "/images/delete",
	  url: $(el).prev().attr 'src'
	index = $div.index()
	images = input.val().split ','
	images.splice index, 1
	input.val images.join ','
	div.parentNode.removeChild div
@deleteImageHeader = (el) ->
	$.get "/images/delete",
	  url: $(el).prev().attr 'src'
	$(el).parents('#addImages').html('<input onclick="addImageClick(this)" type="button" value="Добавить изображение в поле header" class="btn btn-primary"><div></div>').next().val('')
@order = ->
	w = $('#orderWindow')
	d = w.find('>:last-child')[0]
	w.fadeIn(300)
	if w
		w[0].parentNode.removeChild w[0]
		$('body')[0].appendChild(w[0])
		height = $(window).height()
		d.style.left = $(window).width() / 2 - d.offsetWidth / 2 + 'px'
		d.style.top = height / 2 - d.offsetHeight / 2 + 'px'
		d.style.maxHeight = height + 'px'
@orderShowAll = ->
	h = $($('#otherInputs')[0])
	wrap = h.parent().parent()
	if h.attr('class') == 'show'
		h.attr('class', '')
		h.animate 'height':'0px', 300
		wrap.animate 'top': parseInt(wrap[0].style.top) + 97 + 'px', 300
	else
		h.attr('class', 'show')
		h.animate 'height':'194px', 300
		top = parseInt(wrap[0].style.top) - 97
		top = 0 if top < 0
		wrap.animate 'top': top + 'px', 300
@cartCount = ->
	count = 0
	cart.forEach (i) ->
		count += i.c
	if count
		cartCounter.style.display = 'block'
		cartCounter.innerHTML = count
	else cartCounter.style.display = 'none'
@option = (el) ->
	next = $(el).next()
	$('div.option').hide 300
	if next.css('display') != 'none'
		next.hide 300
	else
		$('.option').each ->
		next.show 300
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
	el.parentNode.parentNode.getElementsByClassName('active')[0].className = ''
	el.className = 'active'
	photoes = document.getElementsByClassName('photoes')[0]
	photoes.getElementsByClassName('active')[0].className = ''
	photoes.children[el.dataset.i].className = 'active'
@productMiniPrev = (el) ->
	wrap = $(el).next()
	slides = wrap.find 'div'
	wrap.prepend slides.slice(-3).clone()
	wrap.css left: '-489px'
	wrap.animate left: 0, 1000, ->
		slides.slice(-3).remove()
@productMiniNext = (el) ->
	wrap = $(el).prev()
	slides = wrap.find 'div'
	wrap.append slides.slice(0, 3).clone()
	wrap.animate left: '-489px', 1000, ->
		slides.slice(0, 3).remove()
		wrap.css left: 0

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
	if order_email.value is ''
		order_email.parentNode.classList.add 'has-error'
		order_email.setAttribute 'placeholder', 'Заполните поле'
		ok = false
	else if /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(order_email.value)
		order_email.parentNode.classList.remove 'has-error'
		order_email.setAttribute 'placeholder', ''
	else
		order_email.parentNode.classList.add 'has-error'
		ok = false
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
@sliderPrev = (el) ->
	products = $(el).next()
	active = products.find('.active').removeClass('active')
	move = active.removeClass('active').prev()
	unless move[0]
		move = products.find('> :last-child')
	if parseInt(move.css('left')) > 0
		move.css left: '-100%', right: '100%'
	active.animate {left: '100%', right: '-100%'}, 2000
	move.addClass('active').animate {left: '0', right: '0'}, 2000	
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
	active.animate {left: '-100%', right: '100%'}, 2000
	move.addClass('active').animate {left: '0', right: '0'}, 2000
	buttons = $(el).parent().find('.buttons')
	buttonNext = buttons.find('.active').removeClass('active').next()
	if buttonNext[0]
		buttonNext.addClass('active')
	else
		buttons.find('> :first-child').addClass('active')
sliderLeft = (steps, products) ->
	active = products.find('.active').removeClass('active')
	move = active.prev()
	time = 2000 / steps
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
	time = 2000 / steps
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
	unless $(el).hasClass('.active')
		buttons = $(el).parent()
		products = buttons.prev()
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
@bannerNext = (wrap) ->
	slides = wrap.find '> *'
	slide = slides.first()
	wrap.append(slide.clone()).addClass 'slide'
	setTimeout ->
		wrap.removeClass 'slide'
		slide.remove()
	, 2000
@slider = ->
	products = $('#slider .wrap')
	@sliderInterval = setInterval ->
		sliderRight 1, products
		bannerNext $ '.banners.second .wrap'
		bannerNext $ '.banners.third .wrap'
		bannerNext $ '.banners.fourth .wrap'
		bannerNext $ '.banners.square .wrap'
	, 10000
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
@addProductFooterImage = (input) ->
	if input.files
		el = $ input
		label = el.parent()
		reader = new FileReader()
		reader.onload = (e) ->
			div = $ '<div/>', style: "display: inline-block; margin-bottom: 10px", html: "<img style='width: 100px; height: 100px; margin: 10px 10px 0; display: block' class='img-thumbnail' src='#{e.target.result}'><small class='btn btn-warning' onclick='$(this).parent().remove()'>Удалить</small>"
			el.before("<input name='product_footer_images[]' onchange='addProductFooterImage(this)' style='display: none' type='file'>").appendTo div
			label.next().append div
		reader.readAsDataURL input.files[0]

@dark =
	open: (name) ->
		$('#blur').addClass 'active'
		$('#dark').fadeIn(300).find("> .#{name}").show()
	close: ->
		$('#blur').removeClass 'active'
		$('#dark').fadeOut(300).find("> div").hide()
@otzyv = -> dark.open 'otzyv'
@otzyvSend = (el) ->
	ok = true
	params = {}
	for input in $(el).parents('.otzyv').find 'input, textarea'
		input = $ input
		val = input.val()
		if val is ''
			ok = false
			input.addClass('error').attr 'placeholder', 'Заполните поле'
		else input.removeClass('error').removeAttr 'placeholder'
		params[input.attr 'name'] = val
	if ok
		$.post '/otzyv', params, ->
			dark.close()
			$('#blur > .main > div').prepend "<div class='notice'>Ваш отзыв появится после проверки модератором.<div class='close' onclick='$(this).parent().remove()'>x</div>"
			$('html, body').scrollTop(0)

@compactMenu = ->
	el = compactMenuToggle
	if el.className is 'active'
		el.className = ''
		$(mainMenuCompact).slideUp 300
	else
		el.className = 'active'
		$(mainMenuCompact).slideDown 300


# Здесь новая логика для картинок товаров

@addProductImage = (el) ->
	el.previousElementSibling.insertAdjacentHTML 'beforeend', "<div style='display:inline-block;margin:10px'><label class='btn btn-success'>Выбрать<input name='product_images[]' style='display:none' onchange='chooseProductImage(this)' type='file'></div></div>"

@chooseProductImage = (el) ->
	reader = new FileReader()
	reader.onload = (e) ->
		label = el.parentNode
		label.style.display = 'none'
		div = label.parentNode
		i = 0
		for el in div.parentNode.children
			break if el is div 
			i++ if el.tagName is 'DIV'
		div.insertAdjacentHTML 'afterbegin', "<input type='hidden' name='position_new_product_images[]' value='#{i}'>"
		div.insertAdjacentHTML 'beforeend', "<img class='img-thumbnail' src='#{e.target.result}' style='display:block;max-width:150px;max-height:150px'><div class='btn btn-warning' onclick='this.parentNode.removeChild(this.parentNode)'>Удалить</div>"
	reader.readAsDataURL el.files[0]

@removeProductImage = (el) ->
	div = el.parentNode
	productImages.insertAdjacentHTML 'beforeend', "<input type='hidden' name='remove_product_images[]' value='#{div.dataset.id}'>"
	div.parentNode.removeChild div

@sortProductImages = ->
	$(productImages).sortable
		revert: true
		update: ->
			i = 0
			for div in Array.prototype.slice.call productImages.children
				if div.tagName is 'DIV'
					input = div.children[0]
					if input.tagName is 'INPUT'
						input.value = i++
					else
						div.insertAdjacentHTML 'afterbegin', "<input type='hidden' name='position_product_images[#{div.dataset.id}]' value='#{i++}'>"

@scrollImage = (el) ->
	d = el.parentNode
	$('html, body').animate(scrollTop: d.offsetTop + d.offsetHeight, '500', 'swing')

# Cart page and cart popup

countTotal = (el) ->
	total = 0
	for i in cart
		total += i.c * parseFloat i.p.replace /\ /g, ''
	el.parentNode.parentNode.getElementsByClassName('total-value')[0].innerHTML = total.toCurrency()
	cartSave()

changeCount = (c, add) ->
	item = c.closest '.item'
	i = cart[item.dataset.i]
	return if add is -1 and i.c is 1
	c.innerHTML = i.c += add
	item.getElementsByClassName('price-value')[0].innerHTML = (i.c * item.dataset.price).toCurrency()
	countTotal item

@cartMinus = (el) ->
	changeCount el.nextElementSibling, -1

@cartPlus = (el) ->
	changeCount el.previousElementSibling, 1

@cartDelete = (el) ->
	item = el.closest '.item'
	cart.splice item.dataset.i, 1
	countTotal item
	item.parentNode.removeChild item

# Cart page

@cartNextPage = (el) ->
	current = el.closest '.active'
	index = -2 + Array.prototype.indexOf.call current.parentNode.children, current
	if index is 1
		for input in current.getElementsByTagName 'input'
			if input.value
				input.nextElementSibling.style.display = ''
			else
				input.nextElementSibling.style.display = 'block'
				err = true
		return if err
	if index is 2
		for field in current.getElementsByClassName 'field'
			unless field.firstElementChild.lastElementChild.style.display is 'none'
				input = field.children[1]
				if input.value
					input.nextElementSibling.style.display = ''
				else
					input.nextElementSibling.style.display = 'block'
					err = true
		return if err
	current.className = ''
	page = current.nextElementSibling
	page.className = 'active'
	cartNav.children[index + 1].className = 'active'
	if index is 0
		count = price = 0
		for item in cart
			count += item.c
			price += item.c * parseFloat item.p.replace /\ /g, ''
		page.getElementsByClassName('total-count')[0].innerHTML = count
		page.getElementsByClassName('total-price')[0].innerHTML = price.toCurrency()
	else
		page.firstElementChild.lastElementChild.innerHTML = current.firstElementChild.lastElementChild.innerHTML

@cartPrevPage = (el) ->
	current = el.closest '.active'
	current.className = ''
	index = -2 + Array.prototype.indexOf.call current.parentNode.children, current
	cartNav.children[index].className = ''
	page = current.previousElementSibling
	page.className = 'active'

@cartChooseDelivery = (el) ->
	for input, i in el.getElementsByTagName 'input'
		if input.checked
			index = i
			break
	page = el.closest '.active'
	switch index
		when 0
			for span in page.querySelectorAll '.field .name span'
				span.style.display = 'inline'
			for b in page.getElementsByTagName 'blockquote'
				b.style.display = 'none'
		when 1
			for span in page.querySelectorAll '.field .name span'
				span.style.display = 'none'
			b = page.getElementsByTagName 'blockquote'
			b[0].style.display = 'block'
			b[1].style.display = 'none'
		when 2
			for span, i in page.querySelectorAll '.field .name span'
				span.style.display = i < 4 and 'inline' or 'none'
			b = page.getElementsByTagName 'blockquote'
			b[0].style.display = 'none'
			b[1].style.display = 'block'
	for err in page.getElementsByClassName 'error'
		err.style.display = 'none'

@cartSubmit = (el) ->
	form = el.closest 'form'
	cartfield = document.createElement 'input'
	cartfield.type = 'hidden'
	cartfield.name = 'cartfield'
	cartfield.value = JSON.stringify cart
	form.appendChild cartfield
	form.submit()