# Record

@record =
	create: (el) ->
		form = $(el).parent()
		params = {}
		for field in form.serializeArray()
			params[field.name] = field.value
		if validate form
			$.post "/admin/model/#{form.data('model-name')}/create", record: params, (resp) ->
				act.notify 'Запись успешно добавлена'

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

@ask = (msg, action, options) ->
	ask = dark.open('ask')
	ask.find('.text p').html msg
	ask.find('.red').click ->
		action(options)
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

# Send

@form_send = (form, msg, cb) ->
	send form.attr('action'), form.serializeArray(), msg, cb
@btn_send = (el, msg, cb) ->
	form_send $(el).parent(), msg, cb
@post = (url, data, cb) ->
	$.post "/admin/#{url}", data, cb, 'json'
@send = (url, data, msg, cb) ->
	post url, data, (d) ->
		notify msg
		cb d if cb
@notify = (msg) ->
	app.notify.html("<i class='icon-checkmark-circle'></i><p>#{msg}</p>").addClass 'show'
	setTimeout ->
		app.notify.removeClass 'show'
	, 3000
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
@validate = (form, cb) ->
	send = true
	form.find('[data-validate]').each ->
		f = $ @
		validates = eval f.data 'validate'
		f_ok = true
		error = f.parent().find('.error')
		for v in validates
			switch v
				when 'presence'
					if f.val() is ''
						f_ok = false
						error.html "Нужно заполнить"
		if f_ok
			error.removeClass('active').html ''
		else
			error.addClass 'active'
		send = f_ok if send
		true
	if send
		cb()

# Word

@word = (word) ->
	localization[word] or localization[word.toLowerCase()] or word

# Tag

@tag =
	add: (el) ->
		form = $ el
		input = form.find 'input[type=text]'
		input.before("<div><i class='icon-close' onclick='rm(this)'></i><p>#{input.val()}</p></div>").val ''
		false

# Remove

@rm = (el) -> $(el).parent().remove()

# Tab

@tab =
	gen: (tabs) ->
		ret = "<div class='nav-tabs'>"
		active = true
		for k of tabs
			ret += "<p onclick='openTab(this)' class='#{if active then active = false; 'active ' else ''}capitalize'>#{k}</p>"
		ret += "</div><div class='tabs'>"
		active = true
		for k, v of tabs
			ret += "<div#{if active then active = false; " class='active'" else ''}>"
			ret += v()
			ret += "</div>"
		ret += "</div>"
		ret