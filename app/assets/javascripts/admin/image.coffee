@image =
	add: (el, type) ->
		@wait = el
		@waitType = type
		ask = dark.open 'images'
	upload: (input) ->
	    if input.files
	    	images = $(input).parent().prev()
	    	for f in input.files
	    		reader = new FileReader()
	    		reader.onload = (e) ->
	    			images.append "<div>
							<div class='btn red remove'></div>
							<a href='#{e.target.result}' data-lightbox='product'><img src='#{e.target.result}'></a>
						</div>"
	    		reader.readAsDataURL f
	load: (el) ->
		el = $ el
		formData = new FormData()
		formData.append "image", image.files[el.parents('.upload-image').data('uploadImage') - 1]
		@send el, formData, (d) ->
			nextBtn = el.toggleClass('blue green').html('<i class="icon-folder8"></i><span>Изображение загружено</span>').attr('onclick', '').next()
			if image.waitType is 'many'
				nextBtn.toggleClass('red blue').attr('onclick', 'image.check(this)').html('<i class="icon-checkbox-unchecked"></i><span>Отметить</span>')
			else
				nextBtn.toggleClass('red purple').attr('onclick', 'image.return(this)').html('<i class="icon-checkmark4"></i><span>Выбрать</span>')
			preview = nextBtn.parents('.upload-image').data('url', d).parent()
			not_all = false
			for img in preview.find('> div')
				unless $(img).data 'url'
					not_all = true
					break
			unless not_all
				upload_all = preview.prev().find('.green').addClass('hidden')
				if image.waitType is 'many'
					upload_all.next().removeClass('hidden')
	loadAll: (el) ->
		el = $ el
		return if el.hasClass 'hidden'
		preview = el.parent().next()
		formData = new FormData()
		for img, i in preview.find '> div'
			formData.append "images[]", image.files[i] unless $(img).data 'url'
		@send el, formData, (d) ->
			el.toggleClass('blue green').addClass('hidden')
			if image.waitType is 'many'
				el.next().removeClass('hidden')
			for img, i in preview.find '> div'
				unless $(img).data 'url'
					$(img).data 'url', d.shift()
					if image.waitType is 'many'
						onclick = 'image.check(this)'
						btn = '<i class="icon-checkbox-unchecked"></i><span>Отметить</span>'
						color = 'blue'
					else
						onclick = 'image.return(this)'
						btn = '<i class="icon-checkmark4"></i><span>Выбрать</span>'
						color = 'purple'
					$(img).find('.green').html('<i class="icon-folder8"></i><span>Изображение загружено</span>').attr('onclick', '').next().toggleClass('red ' + color).attr('onclick', onclick).html btn
	send: (el, formData, callback) ->
		$.ajax
			url: "/admin/images/upload"
			type: "POST"
			data: formData
			dataType: 'json'
			processData: false
			contentType: false
			success: (d) ->
				clearInterval interval
				callback d
		el.toggleClass 'green blue'
		points = '...'
		cb = ->
			points = switch points
				when '.'
					'..'
				when '..'
					'...'
				else
					'.'
			el.html 'Идет загрузка' + points
		cb()
		interval = setInterval cb, 1000
	remove: (el) ->
		preview = $(el).parents('.image-preview')
		if preview.find('> div').length is 1
			preview.prev().find('.green').addClass 'hidden'
		act.remove.parents el, '.upload-image'
	return: (el) ->
		image = $(el).parents('.upload-image')
		url = image.data('url')
		if @waitType is 'one'
			$(@wait).addClass('hidden').next().removeClass('hidden').next().removeClass('hidden').parent().next().removeClass('empty').html "<a href='/images/#{url}' data-lightbox='images'><img src='/images/#{url}'><input type='hidden' name='record[image]' value='#{url}'></a>"
		else
			@wait "/images/#{url}"
		dark.close()
		@clearWindow image.parent()
	returnAll: (el) ->
		images = $(@wait).next().removeClass('hidden').next().removeClass('hidden').parent().next()
		preview = $(el).parent().next()
		preview.find('.icon-checkbox-checked').each ->
			url = $(@).parents('.upload-image').data 'url'
			images.append "<a href='/images/#{url}' data-lightbox='images'><img src='/images/#{url}'><input type='hidden' name='images_urls[]' value='#{url}'></a>"
		dark.close()
		images.removeClass('empty').sortable revert: true
		@clearWindow preview
	clearWindow: (el) ->
		file = el.html('').prev()
		file.find('.green').addClass('hidden').html("<i class='icon-upload'></i><span>Загрузить все</span>")
		file.find('.purple').addClass('hidden').html("<i class='icon-checkmark4'></i><span>Выбрать все</span>")
	chooseToDel: (el, server) ->
		el = $ el
		server ||= false
		if el.hasClass 'green'
			action = ''
		else
			action = "image.removeFromInput(this, #{server}); return false"
		el.toggleClass('red green').parent().next().find('a').attr 'onclick', action
	removeOne: (el, server) ->
		control = $(el).parent()
		control.find('.red').addClass 'hidden'
		control.find('.blue').removeClass 'hidden'
		removeFromInput control.next().addClass('empty').find('a'), server
	removeFromInput: (el, server) ->
		el = $ el
		image = el.attr 'href'
		el.remove()
		if server
			$.post '/admin/images/destroy', image: image, (d) ->
				console.log d
			, 'json'
	check: (el) ->
		el = $ el
		el.find('i').toggleClass 'icon-checkbox-unchecked icon-checkbox-checked'
		imagePreview = el.parents '.image-preview'
		chooseAll = imagePreview.prev().find('.purple')
		if imagePreview.find('.icon-checkbox-checked').length
			chooseAll.removeClass 'hidden'
		else
			chooseAll.addClass 'hidden'
	checkAll: (el) ->
		parent = $(el).parent()
		if $(el).find('i').toggleClass('icon-checkbox-unchecked icon-checkbox-checked').hasClass 'icon-checkbox-checked'
			parent.next().find('.icon-checkbox-unchecked').toggleClass('icon-checkbox-unchecked icon-checkbox-checked')
			parent.find('.purple').removeClass 'hidden'
		else
			parent.next().find('.icon-checkbox-checked').toggleClass('icon-checkbox-unchecked icon-checkbox-checked')
			parent.find('.purple').addClass 'hidden'
	files: []