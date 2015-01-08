#= require jquery
#= require jquery_ujs
#= require_tree .

@app =
	routesSorted: {}
	data:
		route: {}
	aclick: (el) ->
		if window.history and history.pushState and $(el).data 'out'
			event.preventDefault()
			app.go $(el).attr 'href'
	routeFind: []
	routes:
		'': {}
		'model/new': {}
		'model/:model/edit': data: ['model/:model/table/indexes']
		'model/:model': {}
		'model/:model/new': {}
		'404': ->
			"<h1>404</h1>
			<div class='content'><br><br><br><br>Такой страницы нет, может скоро будет.<br><br><br><br></div>"
		'welcome': {}
		'components': {}
		'controllers': data: ['controllers']
		'controllers/:contr': data: ['controllers/:controller/code']
		'packinglist': {}
		'packinglist/:id': {}
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
	for f in find
		for a, i in f
			if a[0] is ':'
				@data.route[a[1..-1]] = @pathArray[i]
			else if a isnt @pathArray[i]
				break
			routeArray.push a
		if routeArray.length is len
			break
		else
			routeArray = []
	route = @routes[routeArray.join '/']
	askData = false
	if route.data
		for r in route.data
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
	if app.page
		route.page = app.page
		app.page = null
		if app.after
			route.after = app.after
			app.after = null
	else if !route.page
		askPage = true
	if askData or askPage
		params = 
			url: url
			type: 'POST'
		if askPage
			params.success = (d) ->
				eval d
				if app.page
					route.page = app.page
					app.page = null
					if app.after
						route.after = app.after
						app.after = null
				app.yield.html route.page()
				route.after() if route.after
		else
			params.success = (d) ->
				$.extend true, app.data, d
			params.dataType = 'json'
		$.ajax params
	else
		@yield.html route.page()
		route.after() if route.after
	if @menu
		@menu.find('.current').removeClass 'current'
		@menu.find('.active').removeClass 'active'
		@menu.find("[href='#{@pathname}']").addClass 'current'
		url = "/admin"
		for part in @pathArray
			url += "/#{part}"
			@menu.find("[href='#{url}']").addClass 'active'
ready = ->
	if data?
		$.extend true, app.data, data()
		for key, val of tables
			if val.pluralize in val.has_many
				val.has_many = val.has_many.filter (word) -> word isnt val.pluralize
				val.has_self = true
			else
				val.has_self = false
			val.records = []
			records = app.data.records[key]
			if records
				for rec in records
					val.records.push rec
			val.full = {}
			val.show_has_many = []
			val.fields =
				string: []
				text: []
			for c in val.columns
				if c.name is 'name'
					val.fields.string = ['name']
					break
			if val.fields.string.length is 0
				for c in val.columns
					if c.name is 'email'
						val.fields.string = ['email']
						break
			if val.fields.string.length is 0
				val.fields.string = ['id']
	app.yield = $ '#yield'
	if !app.menu and tables
		app.menu = $ '#menu'
		ret = "<div>
					<a href='/' data-out>
						<i class='icon-home4'></i>
						<span>На главную</span>
					</a>
				</div>
			<div>
				<a href='/admin/packinglist'>
					<i class='icon-credit'></i>
					<span>Список накладных</span>
				</a>
			</div>
			<div>
				<a href='/users/sing_out'>
					<i class='icon-exit'></i>
					<span>Выход</span>
				</a>
			</div>"
		app.menu.html ret
	app.notify = $ '#notify'
	app.go(app.pathname = window.location.pathname)
	$('a').click ->
		app.aclick(@)
$(document).ready ready