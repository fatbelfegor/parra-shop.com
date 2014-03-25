window.getCookie = (name) ->
	matches = document.cookie.match(new RegExp("(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, "\\$1") + "=([^;]*)"))
	(if matches then decodeURIComponent(matches[1]) else `undefined`)

window.expire = ->
	new Date(new Date().setDate(new Date().getDate()+30))

window.addToCart = (name, price) ->
	if $('#alert').get().length == 0
		$('body').append('<div id="alert"><div onclick="$(this.parentNode).fadeOut(300)"></div><div style="top:'+($(window).height()/2-150)+'px; left:'+($(window).width()/2-200)+'px"><div><div onclick="$(this.parentNode.parentNode.parentNode).fadeOut(300)"></div></div><p>Товар "'+name+'" добавлен в <a href="/cart">корзину</a>.</p><a class="continue" onclick="$(this.parentNode.parentNode).fadeOut(300)">Продолжить покупки</a></div></div>')
	$('#alert').fadeIn(300)
	prev = (cart.filter (item) ->
		item.name == name)[0]
	if prev
		prev.count++
	else
		cart.push name: name, count: 1, price: price	
	count = 0
	cart.forEach (i) ->
		count += i.count
	$('#cartCount').html(count)
	document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()