# DropDown

@dropdown =
	toggle: (el) ->
		$(el).toggleClass 'active'
	pick: (el, options) ->
		el = $ el
		val = el.html()
		dropdown.find('input').val val
		if options
			options.cb val if options.cb
			val = options.valueWrap val if options.valueWrap
		dropdown = el.parents('.dropdown')
		dropdown.find('.active').removeClass 'active'
		el.addClass 'active'
		dropdown.find('> p').html val

# TreeBox

@treebox =
	toggle: (el) ->
		$(el).parent().toggleClass 'active'
	pick: (el) ->
		el = $ el
		val = el.html()
		treebox = el.parents('.treebox').removeClass 'active'
		treebox.find('> p').html "<span>#{val}</span><i class='icon-arrow-down2'></i>"
		treebox.find('input').val el.data 'val'

# Record

@record =
	create: (el) ->
		form = $(el).parent()
		params = {}
		for field in form.serializeArray()
			params[field.name] = field.value
		if validate form
			$.post "/admin/model/#{form.data('model-name')}/create", record: params, (resp) ->
				notify 'Запись успешно добавлена'

# Validate

@validate = (form) ->
	form.find('.error').remove()
	ok = true
	for input in form.find('input')
		switch input.type
			when 'text'
				if input.value == ''
					unless $(input).data('null')
						$(input).after "<p class='error'><i class='icon-spam'></i><span>Заполните поле</span></p>"
						ok = false
	ok

# Ask

@ask = (el, msg, action) ->
	ask = dark.open('ask')
	ask.find('.text p').html msg
	ask.find('.red').click ->
		action el
		dark.close()

# Dark

@dark =
	close: ->
		dark = $('#dark').removeClass('show')
		dark.find('.show').removeClass('show')
	open: (name) ->
		dark = $('#dark').addClass('show')
		dark.find(".#{name}").addClass('show')

# Menu

@menu =
	remove: (url) ->
		$('#menu').find("[href='/admin/#{url}']").parent().slideUp 300, ->
			$(@).remove()

# Form

@act =
	remove:
		parent: (el) ->
			$(el).parent().remove()
		parents: (el, parent) ->
			$(el).parents(parent).remove()
		tag: (el) ->
			el = $ el
			val = el.next().html()
			tag = el.parent()
			tag.parent().prev().find('div .hidden').each ->
				el = $ @
				el.removeClass 'hidden' if el.html() is val
			tag.remove()
	ajax: (url, data, msg, cb) ->
		$.ajax
			url: "/admin/#{url}"
			type: "POST"
			data: data
			dataType: 'json'
			success: (d) ->
				act.notify msg
				cb d if cb
	form: (form, msg, cb) ->
		@ajax form.attr('action'), form.serializeArray(), msg, cb
	notify: (msg) ->
		app.notify.html("<i class='icon-checkmark-circle'></i><p>#{msg}</p>").addClass 'show'
		setTimeout ->
				app.notify.removeClass 'show'
			, 3000
	send: (el, msg, cb) ->
		act.form $(el).parent(), msg, cb
@image =
	add: (el, type) ->
		@wait = el
		@waitType = type
		ask = dark.open 'images'
	fileUpload: (input) ->
	    if input.files
	    	label = $(input).parent()
	    	i = $('[data-upload-image]').last().data 'uploadImage'
	    	i ||= 0
	    	for f in input.files
	    		reader = new FileReader()
	    		reader.onload = (e) ->
	    			label.parent().next().append "<div class='upload-image' data-upload-image='#{i += 1}'>
	    				<div class='image'>
	    					<img src='#{e.target.result}'>
	    				</div>
	    				<div>
	    					<p class='title'><b>Название:</b> #{f.name}</p>
	    					<p><b>Ширина:</b> <span class='width'></span>px</p>
	    					<p><b>Высота:</b> <span class='height'></span>px</p>
	    					<p><b>Размер: </b> #{Math.ceil f.size / 1024}Kb</p>
	    				</div>
	    				<div class='buttons'>
	    					<div class='btn green square' onclick='image.load(this)'><i class='icon-upload'></i><span>Загрузить</span></div>
	    					<div class='btn red square' onclick='image.remove(this)'><i class='icon-remove3'></i><span>Удалить</span></div>
	    				</div>
	    			</div>"
	    			$('<img class="hidden"/>').attr('src', e.target.result).load ->
	    				img = $("[data-upload-image='#{i}']")
	    				img.find('.width').html @width
	    				img.find('.height').html @height
	    		reader.readAsDataURL f
	    		image.files.push f
	    	label.next().removeClass('hidden').html("<i class='icon-upload'></i><span>Загрузить все</span>").next().addClass 'hidden'
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
		control.find('.deepblue').removeClass 'hidden'
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
@textarea =
	in: (el) ->
		el = $ el
		active = el.prev.find('.active')
		active.html el.val()
@controller =
	code:
		update: (el) ->
			el = $ el
			form = el.parent()
			form.find('[name=code]').val aceEditor.getValue()
			act.form form, 'Контроллер обновлен', (d) ->
				console.log d
	action:
		create: (el) ->
			act.send el, 'Действие добавлено', (d) ->
				console.log d
@openTab = (el) ->
	el = $ el
	nav = el.parent()
	nav.find('.active').removeClass 'active'
	tabs = nav.next()
	tabs.find('> .active').removeClass 'active'
	tabs.find('> div').eq(el.addClass('active').index()).addClass 'active'
@radio = (el) ->
	el = $ el
	form = el.parents('form')
	radios = form.find("[name=#{el.attr 'name'}]").each ->
		if @.checked
			$(@).parent().addClass 'checked'
		else
			$(@).parent().removeClass 'checked'
@checkbox = (el) ->
	$(el).parent().toggleClass 'checked'