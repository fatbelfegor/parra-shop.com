form = document.getElementsByClassName('cart-pages')[0]

store = localStorage.getItem "cart"
if store
	store = JSON.parse store
	for k, v of store
		form.elements[k].value = v
	radios = form.getElementsByClassName('radios')[0]
	tab = radios.parentNode.parentNode.parentNode
	tab.className = 'active'
	cartChooseDelivery radios
	tab.className = ''
else
	store = {}

form.addEventListener 'change', (e) ->
	store[e.target.name] = e.target.value
	localStorage.setItem "cart", JSON.stringify store