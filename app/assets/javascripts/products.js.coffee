iframe = document.createElement 'iframe'
images = []

window.ready = ->
	$('#addImages').click ->
		iframe.src = '/images/new'
		document.body.appendChild iframe

window.addImageUrl = (url) ->
	iframe.parentNode.removeChild iframe
	images.push url
	$('#products_images').val(images.join(','))