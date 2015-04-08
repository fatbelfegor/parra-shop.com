Number.prototype.toCurrency = ->
	(""+this.toFixed(2)).replace(/\B(?=(\d{3})+(?!\d))/g, " ")
String.prototype.toNumber = ->
	parseFloat @replace(/\ /g,'')
String.prototype.toCurrency = ->
	@toNumber().toCurrency()

# Validate

@validate = (el) ->
	el = $ el
	val = el.val()
	msg = []
	v = el.data 'validate'
	div = el.next()
	active = false
	cb = ->
		if v.presence
			if val is ''
				active = true
				msg.push "Поле не должно быть пустым"
		if v.email
			unless /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i.test val
				active = true
				msg.push "E-mail введён неверно"
		if v.minLength
			if val.length < v.minLength
				active = true
				if v.minLength < 2
					end = ''
				else if v.minLength < 5
					end = 'а'
				else
					end = 'ов'
				msg.push "Значение должно содержать минимум #{v.minLength} знак#{end}"
		if active
			div.addClass('active').find('p').html msg.join '. '
		else
			div.removeClass 'active'
	if v
		if v.uniq and val isnt el.data 'validateWas'
			post 'checkuniq', model: param.model, field: el.attr('name'), val: val, (nil) ->
				if nil isnt true
					active = true
					msg.push "Такое значение уже есть"
				cb()
		else
			cb()

# Ask

@ask = (msg, params) ->
	ask = dark.open('ask')
	ask.find('.text p').html msg
	btn = ask.find '.ok'
	if params.ok
		if params.ok.html
			btn.html params.ok.html
		if params.ok.class
			btn.attr 'class', 'btn ' + params.ok.class
	btn.off 'click'
	btn.click ->
		params.action()
		dark.close()
	if params.cancel
		ask.find('.cancel').click ->
			params.cancel()
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
@send = (url, data, msg) ->
	post url, data, (d) ->
		notify msg
@notify = (msg, options) ->
	clas = 'show'
	if options
		if options.class
			clas += ' ' + options.class
	app.notify.html("<i class='icon-checkmark-circle'></i><p>#{msg}</p>").attr 'class', clas
	setTimeout ->
		app.notify.attr 'class', ''
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

@editorimage =
	add: (cb) ->
		@cb = cb
		dark.open 'image'
	open: (input) ->
		if input.files
			$input = $ input
			label = $input.parent()
			controls = label.parent()
			controls.find('.hidden').removeClass 'hidden'
			preview = controls.next()
			reader = new FileReader()
			reader.onload = (e) ->
				preview.append "<a href='#{e.target.result}' data-lightbox='product'><img src='#{e.target.result}'></a>"
			reader.readAsDataURL input.files[0]
			label.addClass 'hidden'
	remove: (el) ->
		controls = $(el).parent()
		controls.find('> *').toggleClass 'hidden'
		input = controls.find 'input'
		input.replaceWith(input = input.clone true)
		controls.next().html ""
	upload: (el) ->
		formData = new FormData()
		formData.append "image", $(el).parent().find('input')[0].files[0]
		$.ajax
			url: "/admin/editorimage"
			data: formData
			type: 'POST'
			contentType: false
			processData: false
			dataType: "json"
			success: (url) ->
				notify 'Изображение загружено'
				dark.close()
				editorimage.cb url
	link: (el) ->
		dark.close()
		editorimage.cb $(el).parent().next().find('input').val()