Number.prototype.toCurrency = ->
	(""+this.toFixed(2)).replace(/\B(?=(\d{3})+(?!\d))/g, " ")
String.prototype.toNumber = ->
	parseFloat @replace(/\ /g,'')
String.prototype.toCurrency = ->
	@toNumber().toCurrency()
String.prototype.classify = ->
	(@charAt(0).toUpperCase() + @slice(1)).replace /(\_\w)/g, (m) -> m[1].toUpperCase()

@paginator =
	go: (el) ->
		el = $ el
		unless el.hasClass 'active'
			paginator.page = parseInt el.html()
			if paginator.page in paginator.ready
				eq = 0
				for i in [0..paginator.page - 1]
					eq += paginator.limit if i and i + 1 in paginator.ready
				$(window).scrollTop paginator.wrap.find('> .group').eq(eq).offset().top - paginator.top + 5
				paginator.pages.find('.active').removeClass 'active'
				el.addClass 'active'
			else
				paginator.load = true
				rec = model: param.model
				rec.offset = offset = (paginator.page - 1) * paginator.limit
				rec.limit = paginator.limit
				rec.select = paginator.select if paginator.select
				rec.belongs_to = paginator.belongs_to if paginator.belongs_to
				rec.has_many = paginator.has_many if paginator.has_many
				rec.ids = paginator.ids if paginator.ids
				rec.order = paginator.order if paginator.order
				get = [rec]
				db.get get, ->
					ret = ''
					for rec in db.select rec
						window.rec = rec
						ret += record()
					eq = 0
					for i in [0..paginator.page - 1]
						eq += paginator.limit if i + 1 in paginator.ready
					rec = paginator.wrap.find('> .group').eq eq - 1
					rec.after ret
					$(window).scrollTop rec.next().offset().top - paginator.top + 5
					paginator.ready.push paginator.page
					paginator.pages.find('.active').removeClass 'active'
					el.addClass 'active'
					paginator.load = false
	prev: () ->
		if paginator.page is 1
			@go paginator.pages.find('.next').prev()[0]
		else @go paginator.pages.find('.active').prev()[0]
	next: () ->
		if paginator.page is paginator.pages.find('div').length - 2
			@go paginator.pages.find('.prev').next()[0]
		else @go paginator.pages.find('.active').next()[0]

@order =
	open: (el) ->
		$(el).next().toggleClass 'active'
	pick: (el) ->
		el = $ el
		if el.hasClass 'icon-arrow-down5'
			where = 'down'
			order = el.next()
		else
			where = 'up'
			order = el.prev()
		column = order.data 'column'
		column += ' DESC' if where is 'up'
		name = order.html()
		el.parents('div').first().removeClass('active').prev().find('b').html name + " <i class='icon-arrow-#{where}5'></i>"
		template = app.templates.index[param.model]
		rec = model: param.model
		rec.limit = template.pagination if template.pagination
		rec.select = template.select if template.select
		rec.belongs_to = template.belongs_to if template.belongs_to
		rec.has_many = template.has_many if template.has_many
		rec.ids = template.ids if template.ids
		rec.order = column
		db.get [rec], ->
			ret = ''
			for rec in db.select rec
				window.rec = rec
				ret += record()
			$('#records').html ret
			if template.pagination
				$(window).scrollTop 0
				paginator.ready = [1]
				paginator.order = column
				paginator.page = 1
				paginator.pages.find('.active').removeClass 'active'
				paginator.pages.find('div').eq(1).addClass 'active'

@filter = (el) ->
	where = []
	$(el).parent().parent().find('input').each ->
		val = $(@).val()
		unless $.trim(val) is ''
			where.push "#{@.name} #{val}"
	where = where.join ' AND '
	if !window.filter_loading
		window.filter_loading = true
		template = app.templates.index[param.model]
		rec = model: param.model
		rec.limit = template.pagination if template.pagination
		rec.select = template.select if template.select
		rec.belongs_to = template.belongs_to if template.belongs_to
		rec.has_many = template.has_many if template.has_many
		rec.ids = template.ids if template.ids
		rec.order = template.order or 'id'
		rec.where = where
		db.get [rec], ->
			recs = db.select rec
			if recs[0]
				ret = ''
				for rec in db.select rec
					window.rec = rec
					ret += record()
				$('#records').html ret
				template = app.templates.index[param.model]
				if template.pagination
					$(window).scrollTop 0
					paginator.ready = [1]
					paginator.order = template.order or 'id'
					paginator.page = 1
					paginator.pages.find('.active').removeClass 'active'
					paginator.pages.find('div').eq(1).addClass 'active'
			window.filter_loading = false
		, -> window.filter_loading = false

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
		if v.custom
			res = eval(v.custom) val
			if !res.ok
				active = true
				msg.push res.msg
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