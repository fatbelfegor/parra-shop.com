iframe = document.createElement 'iframe'
images = []

window.ready = ->
	$('#addImages input').click ->
		iframe.src = '/images/new'
		this.parentNode.appendChild iframe

window.addImageUrl = (url) ->
	iframe.parentNode.removeChild iframe
	images.push url
	imagesHtml = ''
	$('#product_images').val(images.join(','))
	for img in images
		imagesHtml += '<img src="/uploads/'+img+'">'
	$('#addImages div').html(imagesHtml)