window.getCookie = (name) ->
	matches = document.cookie.match(new RegExp("(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, "\\$1") + "=([^;]*)"))
	(if matches then decodeURIComponent(matches[1]) else `undefined`)

window.expire = ->
	new Date(new Date().setDate(new Date().getDate()+30))

window.addToCart = (name, price) ->
	prev = (cart.filter (item) ->
			item.name == name)[0]
	if prev
		prev.count++
	else
		cart.push name: name, count: 1, price: price	
	document.cookie = 'cart='+JSON.stringify(cart)+';path=/;expires='+expire().toUTCString()