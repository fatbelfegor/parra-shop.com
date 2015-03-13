@treebox =
	toggle: (el) ->
		$(el).parent().toggleClass 'active'
	pick: (el) ->
		el = $ el
		treebox = el.parents '.treebox'
		header = treebox.find '> p'
		input = treebox.find 'input'
		if el.hasClass 'active'
			el.removeClass 'active'
			header.removeClass('active').html header.data 'default'
			input.val ''
		else
			treebox.removeClass('active').find('.active').removeClass 'active'
			el.addClass 'active'
			data = el.data()
			if data.header
				header.addClass('active').html data.header
			else if data.header is undefined
				header.addClass('active').html el.prev().html()
			if data.val
				input.val data.val
			else if data.val is undefined
				input.val el.prev().html()
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
	gen: (params) ->
		params.tag ||= 'div'
		params.header ||= 'Выбрать'
		index = $('.treebox').length
		cb = params.cb || {}
		@cb.push cb
		rec_id = params.rec.id if params.rec
		ret = "<#{params.tag}
			data-index='#{index}'
			data-treebox='#{JSON.stringify params.data}'
			data-pick='#{JSON.stringify params.pick}'
			#{if rec_id then " data-rec-id='#{rec_id}'" else ''}
			#{if params.colspan then " colspan='#{params.colspan}'" else ''}
			#{if params.rowspan then " rowspan='#{params.rowspan}'" else ''}
			#{if params.style then " style='#{params.style}'" else ''}
			class='treebox#{if params.classes then ' ' + params.classes.join ' ' else ''}'>
				<p
					data-default='#{params.header}'
					onclick='treebox.start(this)'
					#{if params.rec then " class='active'>" + params.rec[params.pick.header] else ">" + params.header}
				</p>
				<ul></ul>
				#{if params.input then "<input type='hidden' name='#{params.input.name}'#{if params.rec then " value='#{params.rec[params.pick.val]}'" else if params.input.value then " value='#{params.input.value}'" else ''}>" else ''}
			</#{params.tag}>"
	start: (el) ->
		tb = $(el).attr('onclick', 'treebox.toggle(this)').parent().addClass 'active'
		tb_data = tb.data()
		wrap = tb.find 'ul'
		params = []
		for k, v of tb_data.treebox
			m = {model: k}
			if v.has_self
				where = {}
				where[k + '_id'] = null
				m.where = where
				m.ids = [k]
			if v.habtm
				m.ids ||= []
				for n, h of v.habtm
					m.ids.push n
			params.push m
		record.load params, ->
			treebox.draw wrap, tb_data, tb_data.treebox
	draw: (wrap, tb_data, data) ->
		ret = ""
		for name, options of data
			if options.has_self
				where = {}
				where[name + '_id'] = null
				recs = models[name].where where
			else recs = models[name].all()
			for rec in recs
				ret += "<li>"
				ret += "<p>#{rec[f]}</p>" for f in options.fields
				if options.pick
					ret += "<i class='icon-checkmark2#{if rec.id is tb_data.recId then ' active' else ''}' data-val='#{rec[tb_data.pick.val]}' data-header='#{rec[tb_data.pick.header]}' onclick='treebox.pick(this)'></i>"
				arrow = false
				if options.has_self
					arrow = true if rec[name + '_ids'].length > 0
				relations = {}
				if options.habtm
					relations.habtm = {}
					for n, h of options.habtm
						ids = rec[n + '_ids']
						if ids.length
							arrow = true
							relations.habtm[n] = ids
						break
				ret += "<i class='icon-arrow-down5' data-relations='#{JSON.stringify relations}' data-id='#{rec.id}' data-model='#{name}' data-treebox='#{JSON.stringify options}' onclick='treebox.open(this)'></i>" if arrow
				ret += "</li>"
		wrap.html ret
	open: (el) ->
		el = $ el
		if el.hasClass 'active'
			el.removeClass 'active'
			el.parent().removeClass 'active'
		else
			el.addClass 'active'
			el.parent().addClass 'active'
			treebox_data = el.parents('.treebox').data()
			data = el.data()
			unless data.ready
				el.data 'ready', true
				m = {model: data.model}
				params = []
				if data.treebox.has_self
					m.where = {}
					m.where[data.model + '_id'] = data.id
					m.ids = [data.model]
				if data.treebox.habtm
					m.ids ||= []
					for n, h of data.treebox.habtm
						m.ids.push n
						params.push model: n, find: data.relations.habtm[n]
						break
				params.push m
				record.load params, ->
					ret = ""
					model = models[data.model]
					if data.treebox.habtm
						for k, v of data.treebox.habtm
							m = models[k]
							recs = m.find data.relations.habtm[k]
							if recs.length > 0
								ret += "<ul>"
								if v.group
									ret += "<li class='group'>
										<p class='capitalize'>#{v.group}</p>
									</li>"
								for rec in m.find data.relations.habtm[k]
									ret += "<li>"
									ret += "<p>#{rec[f]}</p>" for f in v.fields
									if v.pick
										ret += "<i class='icon-checkmark2#{if rec.id is treebox_data.recId then ' active' else ''}' data-val='#{rec[treebox_data.pick.val]}' data-header='#{rec[treebox_data.pick.header]}' onclick='treebox.pick(this)'></i>"
									else
										arrow = false
										relations = {}
										if v.has_self
											arrow = true if rec[m.model + '_ids'].length > 0
										if v.habtm
											relations.habtm = {}
											for l, b of v.habtm
												ids = rec[l + '_ids']
												if ids.length
													arrow = true
													relations.habtm[l] = ids
												break
										ret += "<i class='icon-arrow-down5' data-relations='#{JSON.stringify relations}' data-id='#{rec.id}' data-model='#{m.name}' data-treebox='#{JSON.stringify v}' onclick='treebox.open(this)'></i>" if arrow
									ret += "</li>"
								ret += "</ul>"
					if data.treebox.has_self
						where = {}
						where[model.name + '_id'] = data.id
						recs = model.where where
						if recs.length > 0
							ret += "<ul>"
							for rec in recs
								ret += "<li>"
								ret += "<p>#{rec[f]}</p>" for f in data.treebox.fields
								if data.treebox.habtm
									arrow = false
									relations = {}
									if data.treebox.has_self
										arrow = true if rec[data.model + '_ids'].length > 0
									if data.treebox.habtm
										relations.habtm = {}
										for n, h of data.treebox.habtm
											ids = rec[n + '_ids']
											if ids.length
												arrow = true
												relations.habtm[n] = ids
											break
									ret += "<i class='icon-arrow-down5' data-relations='#{JSON.stringify relations}' data-id='#{rec.id}' data-model='#{data.model}' data-treebox='#{JSON.stringify data.treebox}' onclick='treebox.open(this)'></i>" if arrow
								ret += "</li>"
							ret += "</ul>"
					el.after ret
	out_click: ->
		$('html').click ->
			$('.treebox').removeClass 'active'
		$('.treebox').click (event) ->
		    event.stopPropagation()
	cb: []