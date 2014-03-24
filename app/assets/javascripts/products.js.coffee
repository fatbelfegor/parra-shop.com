iframe = document.createElement 'iframe'
images = []

window.ready = ->
	$('#addImages input').click ->
		iframe.src = '/images/new'
		this.parentNode.appendChild iframe
	window.cart = eval getCookie 'cart'
	console.log cart
	if $('#cart')
		items = ''
		for item in cart
			if item.count > 1
				minus = '<span onclick="changeCount(this)">++</span>'
			else
				minus = '<span class="invis">++</span>'
			items += '<ul><li>'+item.name+'</li><li>'+minus+'<b>'+item.count+'</b>'+' <span onclick="changeCount(this)">+</span></li><li>'+item.price+'</li><li></li></ul>'
		$('#cart div').html(items)
		window.changeCount = (el) ->
			ul = el.parentNode.parentNode
			name = ul.firstChild.innerHTML
			item = (cart.filter (item) ->
				item.name == name)[0]
			console.log el.innerHTML
			if el.innerHTML == '+'									
				item.count++
				if item.count > 1
					$(ul).find('.invis').attr('class', '').click ->
						changeCount(this)
			else
				item.count--
				if item.count == 1
					$(ul).find('li span:first-child').attr('class', 'invis')
			$(ul).find('b').html(item.count)
			document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()

window.addImageUrl = (url) ->
	iframe.parentNode.removeChild iframe
	images.push url
	imagesHtml = ''
	$('#product_images').val(images.join(','))
	for img in images
		imagesHtml += '<img src="/uploads/'+img+'">'
	$('#addImages div').html(imagesHtml)