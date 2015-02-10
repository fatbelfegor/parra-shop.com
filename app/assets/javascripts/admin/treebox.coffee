@treebox =
	toggle: (el) ->
		$(el).parent().toggleClass 'active'
	pick: (el) ->
		el = $ el
		unless el.hasClass 'active'
			treebox = el.parents '.treebox'
			treebox.find('.icon-checkmark2.active').removeClass 'active'
			treebox.find('li.active').removeClass 'active'
			treebox.removeClass 'active'
			el.addClass 'active'
			header = treebox.find '> p'
			input = treebox.find 'input'
			data = el.data()
			if data.header
				header.html data.header
			else if data.header is undefined
				header.html el.prev().html()
			if data.val
				input.val data.val
			else if data.val is undefined
				input.val el.html()
			cb = @cb[treebox.data 'index']
			params =
				treebox: treebox
				header: header
				el: el
			for k, v of cb
				cb[k] params if cb[k]
	find_model: (model, hash) ->
		ret = false
		if hash[model]
			ret = hash[model]
		else
			for k, v of hash
				if v.habtm
					ret = @find_model model, v.habtm
					break if ret
		ret
	draw: (model, recs, data, pick) ->
		options = @find_model model, data
		if recs.records.length > 0
			ret = "<ul>"
			if options.group
				ret += "<li class='group'>
					<p class='capitalize'>#{options.group}</p>
				</li>"
			for rec, i in recs.records
				ret += "<li>
					<p>#{rec.name}</p>"
				arrow = false
				if recs.children and recs.children[i] > 0
					arrow = true
				else if recs.habtm
					for k, v of recs.habtm
						if v[i].length > 0
							arrow = true
				if options.pick
					ret += "<i data-id='#{rec.id}'"
					if pick
						ret += " data-val='#{rec[pick.val]}'" if pick.val
						if pick.header
							ret += " data-header='#{rec[pick.header]}'"
						else if pick.header is false
							ret += " data-header='false'"
					ret += " class='icon-checkmark2' onclick='treebox.pick(this)'></i>"
				ret += "<i class='icon-arrow-down5' data-id='#{rec.id}' data-model='#{model}' onclick='treebox.open(this)'></i>" if arrow
				ret += "</li>"
			ret + "</ul>"
		else ""
	gen: (params) ->
		params.tag ||= 'div'
		params.header ||= 'Выбрать'
		for model, v of params.data
			options = {}
			options.where = {}
			if tables.has_self
				options.where[model + '_id'] = null
				options.children = true
			if v.habtm
				options.habtm = []
				options.habtm.push k for k of v.habtm
			recs = record.where model, options
		index = $('.treebox').length
		cb = params.cb || {}
		@cb.push cb
		ret = "<#{params.tag} data-index='#{index}' data-treebox='#{JSON.stringify params.data}' data-pick='#{JSON.stringify params.pick}' class='treebox"
		ret += ' ' + params.classes.join ' ' if params.classes
		ret += "'><p onclick='treebox.toggle(this)'>#{params.header}</p>#{@draw model, recs, params.data, params.pick, index}"
		if params.input
			ret += "<input type='hidden' name='#{params.input.name}'"
			ret += "value='#{params.input.value}'>" if params.input.value
		ret + "</#{params.tag}>"
	open: (el) ->
		el = $ el
		li = el.parent()
		if li.hasClass 'active'
			li.removeClass 'active'
			li.find('li.active').removeClass 'active'
		else
			li.addClass 'active'
		unless el.data 'ready'
			el.data 'ready', true
			id = el.data 'id'
			model = el.data 'model'
			where = []
			wrap = el.parents '.treebox'
			data = eval wrap.data 'treebox'
			pick = wrap.data 'pick'
			pick = eval pick if pick
			table = tables[model]
			plur = table.pluralize
			if tables[model].has_self
				mainpush = model: model, where: {}
				mainpush.where["#{model}_id"] = id
			if data[model].habtm
				mainpush.habtm = []
				for m of data[model].habtm
					mainpush.habtm.push m
					push = model: m, includes: [plur], where: {}
					push.where[plur] = {id: id}
					where.push push
			where.push mainpush
			record.ask where, ->
				where = {}
				where["#{model}_id"] = id
				recs = record.where model, where: where, children: true, habtm: mainpush.habtm
				ret = ""
				ret += treebox.draw model, recs, data, pick
				rec = record.find model, id, habtm: mainpush.habtm
				for k, v of rec.habtm
					ret += treebox.draw k, record.where(k, in: {id: v}), data, pick
				el.after ret
	out_click: ->
		$('html').click ->
			$('.treebox').removeClass 'active'
		$('.treebox').click (event) ->
		    event.stopPropagation()
	cb: []