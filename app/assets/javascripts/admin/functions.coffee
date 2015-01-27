# DropDown

@dropdown =
	toggle: (el) ->
		$(el).toggleClass 'active'
	pick: (el, options) ->
		el = $ el
		val = el.html()
		dropdown = el.parents('.dropdown')
		dropdown.find('input').val val
		if options
			options.cb val if options.cb
			val = options.valueWrap val if options.valueWrap
		dropdown.find('.active').removeClass 'active'
		el.addClass 'active'
		dropdown.find('> p').html val

# TreeBox

@treebox =
	toggle: (el) ->
		$(el).parent().toggleClass 'active'
		window.tree = $(el).parent()
	pick: (el) ->
		el = $ el
		val = el.html()
		treebox = el.parents('.treebox').removeClass 'active'
		treebox.find('> p').html "<span>#{val}</span><i class='icon-arrow-down2'></i>"
		treebox.find('input').val el.data 'val'
	belongs_to: (belongs_to_col, width, rec) ->
		belongs_model = belongs_to_col.name[0..-4]
		ret = "<div#{width} class='treebox-row'>
			<b>#{word tables[belongs_model].name}:</b>
			<div class='treebox' id='treebox_#{belongs_to_col.name}'>"
		treeboxFill = (name) ->
			belongs_table = tables[name]
			field = settings.template.form.model[name] or settings.template.form.common
			field = field.treebox[0].name
			records = belongs_table.records
			if records.length
				ret = "<p onclick='treebox.toggle(this)'><span>"
				if rec and rec[belongs_to_col.name]
					bt_id = rec[belongs_to_col.name]
					for bt_rec in belongs_table.records
						if bt_rec.id is bt_id
							ret += bt_rec[field]
							break
				else if app.data.route.vars[belongs_to_col.name]
					bt_id = parseInt app.data.route.vars[belongs_to_col.name]
					for bt_rec in belongs_table.records
						if bt_rec.id is bt_id
							ret += bt_rec[field]
							break
				else
					ret += "Выбрать"
				ret += "</span><i class='icon-arrow-down2'></i></p>"
				ret += "<ul>"
				if belongs_table.has_self
					roots = []
					roots.push bt_rec if bt_rec.record[belongs_to_col.name] is null for bt_rec in records
					for bt_rec in roots
						ret += "<li>"
						if bt_rec.children > 0
							ret += "<div><i class='icon-arrow-down2' onclick='record.treebox(this, \"#{name}\")'></i><p onclick='treebox.pick(this)' data-val='#{rec.id}'>#{rec[field]}</p></div><ul></ul>"
						else
							ret += "<div><p onclick='treebox.pick(this)' data-val='#{bt_rec.id}'>#{bt_rec[field]}</p></div>"
						ret += "</li>"
				else
					ret += "<li><div><p onclick='treebox.pick(this)' data-val='#{bt_rec.id}'>#{bt_rec[field]}</p></div></li>" for bt_rec in records
				ret += "</ul>"
			else
				ret = "<p><span>Нет записей</span></p>"
			if rec
				val = record.val rec, belongs_to_col
			else if bt_id
				val = " value='#{bt_id}'"
			else
				val = ''
			ret + "<input type='hidden' data-type='integer' name='record[#{name}_id]'#{val}>"
		record.ask {model: belongs_model}, (name) ->
			$("#treebox_#{name}_id").html treeboxFill name
		, (name) ->
			ret += treeboxFill name
		ret + "</div></div>"

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

@ask = (el, msg, action) ->
	ask = dark.open('ask')
	ask.find('.text p').html msg
	ask.find('.red').attr 'onclick', action

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
	post: (url, data, cb) ->
		$.post "/admin/#{url}", data, cb, 'json'
	sendData: (url, data, msg, cb) ->
		@post url, data, (d) ->
				act.notify msg
				cb d if cb
	form: (form, msg, cb) ->
		@sendData form.attr('action'), form.serializeArray(), msg, cb
	send: (el, msg, cb) ->
		@form $(el).parent(), msg, cb
	notify: (msg) ->
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
	settings.localization[word] or settings.localization[word.toLowerCase()] or word

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