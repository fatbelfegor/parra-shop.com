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
	routeFind: []
	routes:
		'': {}
		'model/:model/edit/:id': {}
		'model/:model/new': {}
		'model/:model/records': {}
		'404': {}
	templates:
		index: {}
		form: {}
for k of app.routes
	app.routeFind.push k.split '/'
app.go = (url, params) ->
	unless @pathname is url
		@pathname = url
		history.pushState {}, '', url
	@pathArray = @pathname.split('?')[0].split('/')[2..-1]
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
	if !@route.page
		$.post url, {}, (d) ->
			eval d
			app.routes[routeString].page()
			delete window.data if window.data
			params.cb() if params and params.cb
	else
		@route.page()
		delete window.data if window.data
		params.cb() if params and params.cb
ready = ->
	app.yield = $ '#yield'
	if !app.menu
		app.menu = $ '#menu'
		app.menu.html "<li><a href='/'><i class='icon-home4'></i><span>На главную</span></a></li>#{if me.role is 'admin' then admin_menu else manager_menu}<li><a rel='nofollow' data-method='delete' href='/users/sign_out'><i class='icon-exit'></i><span>Выход</span></a></li>"
	app.notify = $ '#notify'
	app.go app.pathname = window.location.pathname
$(document).ready ready