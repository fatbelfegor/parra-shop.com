#= require jquery
#= require jquery_ujs
#= require_self
#= require_tree

@app =
	routesSorted: {}
	data:
		route: {}
	aclick: (el, options) ->
		if window.history and history.pushState
			event.preventDefault()
			@options ||= {}
			@options.ref = @pathname
			app.go $(el).attr 'href'
	redirect: (path, options) ->
		if window.history and history.pushState
			@options ||= {}
			@options.ref = @pathname
			app.go path
		else window.location.href path
	backButton: (title, ref) ->
		$('#backButton').addClass('active').attr('href', ref).find('span').html title
	routeFind: []
	routes:
		'': {}
		'model': {}
		'model/new': {}
		'model/habtm': {}
		'model/:model/edit': {}
		'model/:model': {}
		'model/:model/new': {}
		'model/:model/records': {}
		'model/:model/index': {}
		'model/:model/templates/index': {}
		'model/:model/templates/form': {}
		'404': ->
			"<h1>404</h1>
			<div class='content'><br><br><br><br>Такой страницы нет, может скоро будет.<br><br><br><br></div>"
		'welcome': {}
		'components': {}
		'packinglist': {}
		'packinglist/:id': {}
	templates:
		index: {}
		form: {}
	scripts: {}
app.routes['model/:model/edit/:id'] = app.routes['model/:model/new']
for k of app.routes
	app.routeFind.push k.split '/'
app.go = (url) ->
	unless @pathname is url
		@pathname = url
		history.pushState {}, '', url
	@pathArray = @pathname.split('/')[2..-1]
	@path = @pathArray.join '/'
	len = @pathArray.length
	find = []
	for f in app.routeFind
		if f.length is len
			find.push f
	routeArray = []
	window.param = {}
	for f in find
		for a, i in f
			if a[0] is ':'
				window.param[a[1..-1]] = @pathArray[i]
			else if a isnt @pathArray[i]
				break
			routeArray.push a
		if routeArray.length is len
			break
		else
			routeArray = []
	routeString = routeArray.join '/'
	@route = @routes[routeString]
	askData = false
	if @route.data
		for r in @route.data
			d = @data
			break if askData
			for p, i in r.split '/'
				if p[0] is ':'
					d = d[@pathArray[i]]
				else
					d = d[p]
				unless d
					askData = true
					break
	askPage = false
	if !@setPage() and !@route.page
		askPage = true
	if @menu
		@menu.find('.current').removeClass 'current'
		@menu.find('.active').removeClass 'active'
		@menu.find('.open').removeClass 'open'
		li = @menu.find "[data-route='#{@path}']"
		if li.length is 0
			li = @menu.find "[data-route='#{routeString}']"
		li.addClass 'current open'
		parent = li.parents('li').eq(0)
		while parent.length
			parent.addClass 'active open'
			parent = parent.parents('li').eq(0)
	app.qparam = {}
	query = window.location.search.substring 1
	vars = query.split '&'
	i = 0
	while i < vars.length
		pair = vars[i].split '='
		if typeof app.qparam[pair[0]] == 'undefined'
			app.qparam[pair[0]] = pair[1]
		else if typeof app.qparam[pair[0]] == 'string'
			arr = [
				app.qparam[pair[0]]
				pair[1]
			]
			app.qparam[pair[0]] = arr
		else
			app.qparam[pair[0]].push pair[1]
		i++
	if askData or askPage
		params = 
			url: url
			type: 'POST'
		if askPage
			params.success = (d) ->
				eval d
				app.setPage()
				app.renderPage()
		else
			params.success = (d) ->
				$.extend true, app.data, d
			params.dataType = 'json'
		$.ajax params
	else
		@renderPage()
app.setPage = ->
	if app.page
		@route.page = app.page
		app.page = null
		if app.after
			@route.after = app.after
			app.after = null
		true
	else false
app.renderPage = ->
	cb = ->
		app.yield.html app.route.page()
		app.route.after() if app.route.after
		app.backButton app.options.back, app.options.ref if app.options and app.options.back
	pre_cb = ->
		if app.preload
			preload = app.preload()
		else
			preload = false
		if preload
			record.load preload, cb
			app.preload = null
		else cb()
	if app.script
		req_scripts = app.script()
		req_scripts = [req_scripts] if typeof req_scripts is 'string'
		load_scripts = []
		for s in req_scripts
			load_scripts.push s if @scripts[s] is undefined
		if load_scripts.length
			$.ajax
				url: "/admin/scripts"
				data: scripts: load_scripts
				dataType: "script"
				success: ->
					for s in load_scripts
						app.scripts[s] = true
					pre_cb()
				error: (data) ->
					app.scripts[data.responseText.match(/admin\/scripts\/(.*?) with/)[1]] = false
					pre_cb()
		else
			pre_cb()
	else pre_cb()
ready = ->
	if window.data
		data = window.data()
		if data.records
			for k, v of data.records
				model = models[k]
				for rec in v.records
					model.collect rec
	app.yield = $ '#yield'
	if !app.menu
		app.menu = $ '#menu'
		ret = "<li>
					<a href='/'>
						<i class='icon-home4'></i>
						<span>На главную</span>
					</a>
				</li>
				<li>
						<div onclick='$(this).parent().toggleClass(\"open\")'><i class='icon-arrow-right11'></i></div>
						<p>
							<i class='icon-table2'></i>
							<span>Модели</span>
						</p>
						<ul>"
		for name, model of models
			model.templates.form = app.templates.form[name] if app.templates.form[name]
			model.templates.index = app.templates.index[name] if app.templates.index[name]
			ret += "<li data-route='model/#{name}'>
				<div class='icon fade'><a href='/admin/model/#{name}/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/#{name}/records' onclick='app.aclick(this)'><i class='icon-stack'></i><span>#{model.classify}</span></a>
			</li>"
		ret += "</ul>
			</li>
			<li data-route='model/order/records'>
				<a href='/admin/model/order/records' onclick='app.aclick(this)'>
					<i class='icon-cart4'></i>
					<span>Заказы</span>
				</a>
			</li>
			<li data-route='packinglist'>
				<a href='/admin/packinglist' onclick='app.aclick(this)'>
					<i class='icon-credit'></i>
					<span>Список накладных</span>
				</a>
			</li>
			<li>
				<div onclick='$(this).parent().toggleClass(\"open\")'><i class='icon-arrow-right11'></i></div>
				<a href='/admin/settings' onclick='app.aclick(this)'>
					<i class='icon-wrench2'></i>
					<span>Настройки</span>
				</a>
				<ul>
					<li>
						<div onclick='$(this).parent().toggleClass(\"open\")'><i class='icon-arrow-right11'></i></div>
						<p>
							<i class='icon-table2'></i>
							<span>Модели</span>
						</p>
						<ul>
							<li>
								<a href='/admin/model/new' onclick='app.aclick(this)'>
									<i class='icon-plus-circle'></i>
									<span>Создать новую</span>
								</a>
							</li>
							<li>
								<a href='/admin/model/habtm' onclick='app.aclick(this)'>
									<i class='icon-loop'></i>
									<span>Создать связь HABTM</span>
								</a>
							</li>"
		for name, model of models
			ret += "<li>
				<div onclick='$(this).parent().toggleClass(\"open\")'><i class='icon-arrow-right11'></i></div>
				<p><i class='icon-stack'></i><span>#{model.classify}</span></p>
				<ul>
					<li><a href='/admin/model/#{name}/edit' onclick='app.aclick(this)'><i class='icon-settings'></i><span>Редактировать модель</span></a></li>
					<li><a href='/admin/model/#{name}/templates/index' onclick='app.aclick(this)'><i class='icon-menu3'></i><span>Все записи</span></a></li>
					<li><a href='/admin/model/#{name}/templates/form' onclick='app.aclick(this)'><i class='icon-pencil3'></i><span>Форма записи</span></a></li>
					<li><a href='/admin/model/#{name}/templates/destroy' onclick='ask(this, &quot;Вы действительно хотите удалить модель <b>#{name}</b>?&quot;, &quot;model.destroy(&#039;#{name}&#039;)&quot;)'><i class='icon-remove3'></i><span>Удалить модель</span></a></li>
				</ul>
			</li>"
		ret += "</ul>
					</li>
					<li>
						<a href='/admin/components' onclick='app.aclick(this)'>
							<i class='icon-share3'></i>
							<span>Компоненты</span>
						</a>
					</li>
				</ul>
			</li>
			<li>
				<a href='/users/sing_out'>
					<i class='icon-exit'></i>
					<span>Выход</span>
				</a>
			</li>"
		app.menu.html ret
	app.notify = $ '#notify'
	app.go app.pathname = window.location.pathname
$(document).ready ready