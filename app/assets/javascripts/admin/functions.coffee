# Прототипы

Number.prototype.toCurrency = ->
	(""+this.toFixed(2)).replace(/\B(?=(\d{3})+(?!\d))/g, " ")
String.prototype.toNumber = ->
	parseFloat @replace(/\ /g,'')
String.prototype.toCurrency = ->
	@toNumber().toCurrency()
String.prototype.classify = ->
	(@charAt(0).toUpperCase() + @slice(1)).replace /(\_\w)/g, (m) -> m[1].toUpperCase()

# Индекс и форма

@field = (header, name, params) ->
	params ?= {}
	val = if window.rec then window.rec[name] else ''
	val = params.val_cb val if params.val_cb
	ret = "<label class='row'#{if params.validation then " style='position: relative'" else ''}>"
	ret += "<p>#{header}</p>" if header isnt ''
	ret += "<input type='#{params.type || 'text'}' name='#{name}'"
	if params.format
		ret += " data-format='#{JSON.stringify params.format}'"
		if val
			if window.rec and params.format.decimal
				if params.format.decimal is "currency"
					val = val.toCurrency() + ' руб.'
			else if params.format.date
				val = new Date(val).toString params.format.date
		else if (params.format.not_null or params.format.decimal or params.format.date) and val is null
			val = ''
	ret += " value='#{val}'"
	onchanges = []
	if params.attrs
		for k, v of params.attrs
			if k is 'onchange'
				onchanges.push v
			else ret += " #{k}='#{v}'"
	if params.validation
		onchanges.push "validate(this)"
		ret += " data-validate-was='#{if window.rec then window.rec[name] else ''}'
			data-validate='#{JSON.stringify params.validation}'"
	ret += "#{if onchanges.length then " onchange='#{onchanges.join ';'}'" else ''}>"
	ret += "<div class='validation'><p></p></div>" if params.validation
	ret + "</label>"
@image_wrap = (name, header) ->
	ret = ""
	name ?= 'image'
	if window.rec and window.rec[name]
		url = window.rec[name]
		ret += "<div class='image'>
			<div class='btn red remove' onclick='image.removeOneImage(this, \"#{name}\", \"#{url}\")'></div>
			<a href='#{url}' data-lightbox='product'><img src='#{url}'></a>
		</div>"
		hide = true
	ret + "<label class='m15 text-center#{if hide then ' hide' else ''}'><div class='btn blue ib'>#{header || 'Добавить изображение'}</div><input class='hide image-file' onchange='window.image.upload(this)' name='#{name}' type='file'></label>"
@image_field = (name, header) -> "<div class='image-form'>#{image_wrap name, header}</div>"

# Пагинация

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

# Сортировать по

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

# Фильтр

@filter =
	open: ->
		wrap = $ "#where"
		if wrap.css('display') is 'none'
			$('#records').animate 'padding-top': 129, 300
			wrap.slideDown 300
		else
			wrap.slideUp 300
			$('#records').animate 'padding-top': 54, 300
	change: (el) ->
		where = []
		$(el).find("[type='text']").each ->
			i = $ @
			val = i.val()
			if val isnt ''
				if @name is 'sql'
					where.push val 
				else
					where.push @name + ' ' + switch i.data 'cb'
						when 'begin'
							"regexp \"^#{val}\""
						else
							val
		where = where.join ' AND '
		if !window.filter_loading
			window.filter_loading = true
			template = app.templates.index[param.model]
			window.tmp = model: param.model
			tmp.limit = template.pagination if template.pagination
			tmp.select = template.select if template.select
			tmp.belongs_to = template.belongs_to if template.belongs_to
			tmp.has_many = template.has_many if template.has_many
			tmp.ids = template.ids if template.ids
			tmp.count = true if template.pagination
			tmp.order = template.order or 'id'
			tmp.where = where
			db.get [tmp], ->
				recs = db.select window.tmp
				if recs[0]
					ret = ''
					for rec in recs
						window.rec = rec
						ret += record()
					$('#records').html ret
					template = app.templates.index[param.model]
					if template.pagination
						$(window).scrollTop 0
						paginator.ready = [1]
						paginator.order = template.order or 'id'
						paginator.page = 1
						pages = "<div class='prev' onclick='paginator.prev()'><i class='icon-arrow-left'></i></div><div class='active' onclick='paginator.go(this)'>1</div>"
						divide = db.count(window.tmp) / template.pagination
						pages += "<div onclick='paginator.go(this)'>#{page}</div>" for page in [2..1 + Math.floor divide] if divide >= 1
						paginator.pages.html pages + "<div class='next' onclick='paginator.next()'><i class='icon-arrow-right2'></i></div>"
				window.filter_loading = false
			, -> window.filter_loading = false
		event.preventDefault()

@fillData = (el, prefix, model, fd) ->
	data = fields: {}
	$el = $ el
	if $el.hasClass 'image-file'
		file = el.files[0]
		fd.append "#{prefix}image[#{el.name}]", file if file
	else if $el.hasClass 'images-file'
		if el.files.length
			label = $el.parent()
			label_index = label.index() + 1
			removeNew = label.parent().data 'removeNew'
			for image, i in el.files
				if !removeNew or "#{label_index}-#{i}" not in removeNew
					fd.append "#{prefix}images[]", image
	else if el.name is 'removeImage'
		field = $el.data 'field'
		data.removeImage = field
		fd.append "#{prefix}removeImage[]", field
	else if el.name is 'removeImages'
		remove_id = $el.parent().data 'id'
		data.removeImages = remove_id
		fd.append "#{prefix}removeImages[]", remove_id
	else if $el.hasClass 'habtm_checkboxes'
		unless data.fields[el.name]
			data.fields[el.name] = []
			unless $el.parents('.checkboxes').eq(0).find('input:checked').length
				fd.append "#{prefix}fields[#{el.name}]", []
		if el.checked
			data.fields[el.name].push parseInt el.value
			fd.append "#{prefix}fields[#{el.name}][]", el.value
	else if el.type is 'checkbox'
		value = el.checked
		data.fields[el.name] = value
		fd.append "#{prefix}fields[#{el.name}]", value
	else
		if el.tagName is 'INPUT'
			value = $el.val()
			format = $el.data 'format'
			if format
				if format.decimal
					if format.decimal is 'currency'
						value = parseFloat(value.replace(' ', ''))
				else if format.date and value isnt ''
					value = Date.parseExact value, format.date
		else if $el.hasClass 'tinyMCE-ready'
			value = tinyMCE.get(el.id).getContent()
		else
			value = $el.val()
		data.fields[el.name] = value
		fd.append "#{prefix}fields[#{el.name}]", value
	data

# Валидатор

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

# Окошко подтверждения

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

# Темный фон

@dark =
	close: ->
		dark = $('#dark').removeClass('show')
		dark.find('.show').removeClass('show')
	open: (name) ->
		dark = $('#dark').addClass('show')
		dark.find(".#{name}").addClass('show')

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