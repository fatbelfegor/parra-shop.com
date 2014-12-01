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
#= require tinymce-jquery
#= require_tree .

Number.prototype.toCurrency = ->
	"#{@.toFixed(2)}".replace(/\B(?=(\d{3})+(?!\d))/g, " ")
String.prototype.toCurrency = ->
	parseFloat(@).toCurrency()
getCookie = (name) ->
	matches = document.cookie.match(new RegExp("(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, "\\$1") + "=([^;]*)"))
	if matches then decodeURIComponent(matches[1]) else 'undefined'
expire = new Date(new Date().setDate(new Date().getDate()+30)).toGMTString()

scrollFunc = ->
	unless window.productLoading
		products = $('#products')
		if products.length > 0
			win = $(this)
			if win.scrollTop() + win.height() > products.offset().top + products.height()
				window.productLoading = true
				productLoad.limit = Math.floor(($('#products').width() + 50) / 350) * Math.ceil(($(window).height() + 10) / 460)
				productLoad.offset = products.find('> div').length
				$.post '/catalog/products', productLoad, (d) ->
					console.log d
					html = ''
					for p in d
						html += "<div><div>"
						if p.product.images
							html += "<div class='left' onclick='product.left(this)'></div><div class='images'><div class='wrap'>"
							for img in p.product.images.split ','
								html += "<a href='#{img}' data-lightbox='images-#{p.product.id}' style=\"background-image: url('#{img}')\"></a>"
							html += "</div></div><div class='right' onclick='product.right(this)'></div>"
						else
							html += "<div class='images'></div>"
						html += "<a href='/kupit/#{p.product.scode}'><b>#{p.product.name}</b>"
						html += "<p>#{p.product.article}</p>" if p.product.article
						html += "<p>Заполнить позже (размер)</p>
									<p>Заполнить позже (цвет)</p>
									<p><b>Цена:</b> <span>#{p.product.price.toCurrency()} руб.</span></p>
								</a>
								<div class='btn-buy'><p>Купить</p></div>
							</div>
						</div>"
					if $('#products').append(html).find('> div').length == 0
						$('#products').html('<p class="notFound">По Вашему запросу ничего не найдено, попробуйте его изменить.</p>')
					window.productLoading = false
window.productLoading = false
@product =
	left: (el) ->
		wrap = $(el).next().find '.wrap'
		images = wrap.find 'a'
		move = images.last()
		if wrap.css('left') == '0px'
			wrap.css('left': "-#{wrap.parent().width()}px").prepend(move.clone()).animate 'left': 0, 500, ->
				move.remove()
	right: (el) ->
		wrap = $(el).prev().find '.wrap'
		images = wrap.find 'a'
		move = images.first()
		wrap.append(move.clone()).animate 'left': "-#{wrap.parent().width()}px", 500, ->
			wrap.css('left': 0)
			move.remove()
	minus: (el) ->
		el = $(el)
		span = el.next()
		number = parseInt span.html()
		return if number == 1
		span.html number -= 1
		product.count el, number
	plus: (el) ->
		el = $(el)
		span = el.prev()
		number = parseInt span.html()
		span.html number += 1
		product.count el, number
	count: (el, number) ->
		id = el.parents('[data-id]').data 'id'
		for product in cart
			if product.id == id
				product.count = number
				document.cookie = "product-#{cart.indexOf(product) + 1}=#{encodeURIComponent(JSON.stringify(product))};path=/;expires=#{expire}"
				break
		@.sum()
	delete: (el) ->
		el = $(el)
		row = el.parents('[data-id]')
		id = row.data 'id'
		for product in cart
			if product.id == id
				cart.splice cart.indexOf(product), 1
				break
		clearProductCookies()
		if cart.length
			row.remove()
			i = 0
			for product in cart
				i += 1
				document.cookie = "product-#{i}=#{encodeURIComponent(JSON.stringify(product))};path=/;expires=#{expire}"
			@.sum()
		else
			$('#cart').html '<p class="empty">Корзина пуста</p>'
	sum: ->
		count = 0
		total = 0
		for product in cart
			count += product.count
			total += (product.price + product.sizePrice + product.colorPrice + product.texturePrice + product.optionPrice) * product.count
		if count == 1
				end = ''
			else if count < 5
				end = 'а'
			else
				end = 'ов'
		$('#sum').html "В корзине <b class='count'>#{count}</b> товар#{end} на сумму <b class='price'>#{total.toCurrency()}</b> руб."
window.cart = []
ready = ->
	windowsOpen 'window-order'
	unless cart.length
		i = 0
		while i += 1
			product = getCookie "product-#{i}"
			break if product == 'undefined'
			cart.push $.parseJSON product
	$('#productsSortable').sortable
		revert: true
		update: ->
			$.post '/products/sort', $(this).sortable 'serialize'
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
	$('body').scroll scrollFunc()
	cartWrap = $('#cart')
	if cartWrap.length
		if cart.length
			html = ''
			count = 0
			total = 0
			for product in cart
				price = product.price + product.sizePrice + product.colorPrice + product.texturePrice + product.optionPrice
				html += "<div data-id='#{product.id}'>
							<div class='images-cell'>
								<div class='left' onclick='product.left(this)'></div>
									<div class='images'>
										<div class='wrap'>"
				for image in product.images.split ','
					html += "<a href='#{image}' data-lightbox='images-cart' style='background-image: url(\"#{image}\")'></a>"
				html += "</div>
						</div>
						<div class='right' onclick='product.right(this)'></div>
					</div>
					<a href='/kupit/#{product.scode}' class='desc'>
						<p class='name'>#{product.name}</p>"
				html += "<p><b>Артикул:</b> #{product.articul}</p>" if product.articul != ''
				html += "<p><b>Размер:</b> #{product.sizeName}</p>" if product.size
				if product.texture
					html += "<p><b>#{product.colorName}</b> #{product.textureName}</p>"
				else if product.color
					html += "<p>#{product.colorName}</p>"
				html += "<p>#{product.optionName}</p>" if product.option
				html += "<p class='price'><b>Цена:</b> #{price.toCurrency()} руб.</p>"
				html += "</a>
					<div class='count'>
						<div class='left' onclick='product.minus(this)'></div>
						<span>#{product.count}</span>
						<div class='right' onclick='product.plus(this)'></div>
					</div>
					<div class='delete'>
						<div onclick='product.delete(this)'>Удалить</div>
					</div>
				</div>"
				count += product.count
				total += price * product.count
			if count == 1
				end = ''
			else if count < 5
				end = 'а'
			else
				end = 'ов'
			html += "<div id='sum'>В корзине <b class='count'>#{count}</b> товар#{end} на сумму <b class='price'>#{total.toCurrency()}</b> руб.</div>"
			cartWrap.html html
		else
			cartWrap.html '<p class="empty">Корзина пуста</p>'
			cartWrap.next().hide()
$(document).ready ->
	ready()
$(document).on('page:load', ready)
iframe = document.createElement 'iframe'
@addImageButton = (el) ->
	if $(el).hasClass('btn-danger')
		img = $(el).toggleClass('btn-danger btn-primary').html('Добавить изображение').find('~ img')
		params = {url: img.attr('src')}
		cat = $(el).parents('form').data('cat')
		params.cat = cat if cat
		product = $(el).parents('form').data('product')
		params.product = product if product
		banner = $(el).parents('form').data('banner')
		params.banner = banner if banner
		$.post '/images/delete', url: params
		img.remove()
	else
		$(el).toggleClass('btn-primary btn-warning')
		if $(el).find('~ iframe').length
			$(el).next().remove()
		else
			iframe.src = '/images/new'
			$(el).after iframe
@addImageUrl = (url) ->
	div = $(iframe).parent()
	if div.hasClass 'addImage'
		$(iframe).prev().toggleClass('btn-warning btn-danger').html('Удалить').after "<img src='#{url}'>"
		$(iframe).find('~ input').val url
		$(iframe).remove()
	else
		$(iframe).prev().toggleClass('btn-warning btn-primary')
		div.append "<img src='#{url}'><p class='btn btn-danger' onclick='imagesDelete(this)'>Удалить</p>"
		input = div.find('input')
		val = input.val()
		if val == ''
			val = url
		else
			val = val.split(',')
			val.push(url)
			val = val.join ','
		input.val val
		$(iframe).remove()
@imagesDelete = (el) ->
	input = $(el).parents('.addImages').find 'input'
	img = $(el).prev()
	url = img.attr 'src'
	val = input.val().split(',')
	index = val.indexOf url
	val.splice index, 1 if index > -1
	input.val val.join ','
	img.remove()
	$(el).remove()
	params = {url: img.attr('src')}
	cat = $(el).parents('form').data('cat')
	params.cat = cat if cat
	product = $(el).parents('form').data('product')
	params.product = product if product
	banner = $(el).parents('form').data('banner')
	params.banner = banner if banner
	$.post '/images/delete', url: params
@imagesDeleteExist = (el) ->
	params = {url: $(el).prev().attr('src')}
	cat = $(el).parents('form').data('cat')
	params.cat = cat if cat
	product = $(el).parents('form').data('product')
	params.product = product if product
	banner = $(el).parents('form').data('banner')
	params.banner = banner if banner
	$.post '/images/delete', params
	imagesDelete el
@imagesMini = (el) ->
	el = $(el)
	unless el.hasClass 'active'
		mini = el.parent()
		mini.find('.active').removeClass 'active'
		el.addClass 'active'
		mini.next().attr 'style', el.attr 'style'
@addTexture = (el) ->
	$(el).after '<div class="addTexture">
      <div class="addImage">
        <p onclick="addImageButton(this)" class="btn btn-primary">Добавить изображение</p>
        <input name="textures[][image]" type="hidden">
      </div>
      <label>Название: <input type="text" name="textures[][name]"></label>
      <label>Код: <input type="text" name="textures[][scode]"></label>
      <label>Цена: <input type="text" name="textures[][price]"></label>
      <div class="btn btn-danger" onclick="$(this).parent().remove()">Удалить</div>
    </div>'
@showHideTextures = (el) ->
	el = $(el).parent().next()
	if el.css('display') == 'none'
		el.show(300)
	else
		el.hide(300)
@checkboxClick = (el) ->
	el = $(el)
	active = el.parents '.active'
	active.find('.checked').removeClass 'checked'
	el.find('.checkbox').addClass 'checked'
	addToPrice = 0
	size = color = option = img = ''
	$('.checked').each ->
		el = $(@)
		parent = el.parent()
		addToPrice += parseFloat parent.data 'price'
		textures = el.parents('.textures')
		if textures.length
			prev = textures.prev()
			addToPrice += parseFloat prev.data 'price'
			color = "#{prev.find('.name').html()}: #{parent.find('.name').html()}"
			img = prev.find('img').attr 'src'
		else
			type = el.parents('.tab').attr('class').split(' ')[0]
			switch type
				when 'prsizes'
					size = parent.find('.name').html()
				when 'prcolors'
					color = parent.find('.name').html()
					img = parent.find('img').attr 'src'
				when 'proptions'
					option = parent.find('.name').html()
	choosed = $('#choosed')
	choosed.find('.size').html size
	choosed.find('.color').html color
	choosed.find('img').attr 'src', img
	option = '' if option == 'Без опции'
	choosed.find('.option').html option
	price = $('#product-price')
	oldPrice = $('#product-old-price')
	price.html (parseFloat(price.data('price')) + addToPrice).toCurrency()
	oldPrice.html (parseFloat(oldPrice.data('price')) + addToPrice).toCurrency()
@tabs = (el) ->
	el = $(el)
	unless el.hasClass 'active'
		tabs = el.parent()
		tabs.find('.active').removeClass 'active'
		el.addClass 'active'
		pages = tabs.next()
		pages.find('.active').removeClass 'active'
		pages.find('> div').eq(el.index()).addClass 'active'
@productPageBuy = ->
	h1 = $('h1')
	product =
		id: h1.data 'id'
		name: h1.html()
		scode: h1.data 'scode'
		price: parseFloat $('#product-price').data 'price'
		images: $('#images').data 'images'
	articul = $('#articul')
	if articul.length
		product.articul = $('#articul').html()
	else
		product.articul = ''
	$('.checked').each ->
		el = $(@)
		type = el.data 'type'
		product["#{type}"] = el.data 'id'
		parent = el.parent()
		if type == 'texture'
			textures = el.parents('.textures')
			product["#{type}Price"] = parseFloat parent.data 'price'
			product["#{type}Name"] = parent.find('.name').html()
			prev = textures.prev()
			product["#{prev.data 'type'}"] = prev.data 'id'
			product["#{prev.data 'type'}Price"] = parseFloat prev.data 'price'
			product["#{prev.data 'type'}Name"] = prev.find('.name').html()
		else
			product["#{type}Price"] = parseFloat parent.data 'price'
			product["#{type}Name"] =parent.find('.name').html()
	for field in ['size', 'color', 'texture', 'option']
		product[field] ||= 0
		product["#{field}Name"] ||= ''
		product["#{field}Price"] ||= 0
	pushCart product
pushCart = (product) ->
	existed = false
	for exist in cart
		product.count = exist.count
		if JSON.stringify(product) == JSON.stringify(exist)
			existed = exist
			break
	if existed
		index = cart.indexOf(existed) + 1
		product.count += 1
		document.cookie = "product-#{index}=#{encodeURIComponent(JSON.stringify(product))};path=/;expires=#{expire}"
	else
		product.count = 1
		cart.push product
		document.cookie = "product-#{cart.length}=#{encodeURIComponent(JSON.stringify(product))};path=/;expires=#{expire}"
	windowsOpen 'window-buy'
	win = $('#window-buy')
	images = ''
	for image in product.images.split ','
		images += "<a href='#{image}' data-lightbox='images-in-window' style='background-image: url(\"#{image}\")'></a>"
	win.find('.wrap').html images
	html = "<h3>#{product.name}</h3>"
	html += "<p><b>Артикул:</b> #{product.articul}</p>" if product.articul != ''
	html += "<p><b>Размер:</b> #{product.sizeName}</p>" if product.size
	if product.texture
		html += "<p><b>#{product.colorName}:</b> #{product.textureName}</p>"
	else if product.color
		html += "<p>#{product.colorName}</p>"
	html += "<p>#{product.optionName}</p>" if product.option
	html += "<p class='price'>
				<b>#{(product.price + product.sizePrice + product.colorPrice + product.texturePrice + product.optionPrice).toCurrency()}</b>
				<i class='icon-rubl'></i>
				<span>× #{product.count}</span>
			</p>"
	win.find('.desc').html html
@clearProductCookies = ->
	i = 0
	while i += 1
		product = getCookie "product-#{i}"
		break if product == 'undefined'
		document.cookie = "product-#{i}=;path=/;expires=Thu, 01 Jan 1970 00:00:01 GMT"
@windowsOpen = (name) ->
	$("##{name}").show()
	$('#windows').fadeIn 300
@windowsClose = ->
	$('#windows, #windows > div').fadeOut 300
@orderDelivery = (el) ->
	el = $(el)
	$('#window-order').toggleClass 'delivery'
@orderValidate = (form) ->
	form = $(form)
	ok = true
	for name in ['order[name]', 'order[phone]']
		input = form.find "[name=#{name}]"
		if input.val() == ''
			ok = false
			input.addClass 'error'
			input.attr 'placeholder', 'Запоните поле'
		else
			input.removeClass 'error'
	email = form.find '[name=order[email]]'
	if /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test email
	    email.removeClass 'error'
	else
		email.addClass 'error'
		email.attr 'placeholder', 'Некорректный e-mail'
	if ok
		form.find('[name=cartfield]').val JSON.stringify cart
	# ok
	# console.log form.find('[name=cartfield]').val()
	false