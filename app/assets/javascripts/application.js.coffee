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
	"#{@.toFixed(2)}".replace(/\B(?=(\d{3})+(?!\d))/g, " ") + ' руб.'
String.prototype.toCurrency = ->
	parseFloat(@).toCurrency()

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
									<p><b>Цена:</b> <span>#{p.product.price.toCurrency()}</span></p>
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
ready = ->
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
@tabs = (el) ->
	el = $(el)
	unless el.hasClass 'active'
		tabs = el.parent()
		tabs.find('.active').removeClass 'active'
		el.addClass 'active'
		pages = tabs.next()
		pages.find('.active').removeClass 'active'
		pages.find('> div').eq(el.index()).addClass 'active'