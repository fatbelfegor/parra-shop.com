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
	btn = ask.find('.ok')
	if params.ok
		if params.ok.html
			btn.html params.ok.html
		if params.ok.class
			btn.attr 'class', 'btn ' + params.ok.class
	btn.click ->
		params.action(params.options)
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