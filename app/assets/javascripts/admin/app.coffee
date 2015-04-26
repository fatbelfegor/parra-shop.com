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
		ret = "<li><a href='/'><i class='icon-home4'></i><span>На главную</span></a></li>"
		if me.role is 'admin'
			ret += "<li data-route='model/category'>
				<div class='icon fade'><a href='/admin/model/category/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/category/records' onclick='app.aclick(this)'><i class='icon-stack'></i><span>Категории</span></a>
			</li>
			<li data-route='model/product'>
				<div class='icon fade'><a href='/admin/model/product/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/product/records' onclick='app.aclick(this)'><i class='icon-stack'></i><span>Товары</span></a>
			</li>
			<li data-route='model/extension'>
				<div class='icon fade'><a href='/admin/model/extension/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/extension/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы товаров</span></a>
			</li>
			<li data-route='model/order/records'>
				<a href='/admin/model/order/records' onclick='app.aclick(this)'>
					<i class='icon-cart4'></i><span>Заказы</span>
				</a>
			</li>
			<li data-route='model/status'>
				<div class='icon fade'><a href='/admin/model/status/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/status/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы заказов</span></a>
			</li>
			<li data-route='model/packinglist'>
				<div class='icon fade'><a href='/admin/model/packinglist/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/packinglist/records' onclick='app.aclick(this)'><i class='icon-credit'></i><span>Список накладных</span></a>
			</li>
			<li data-route='model/banner'>
				<div class='icon fade'><a href='/admin/model/banner/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/banner/records' onclick='app.aclick(this)'><i class='icon-image'></i><span>Баннеры</span></a>
			</li>
			<li data-route='model/user'>
				<div class='icon fade'><a href='/admin/model/user/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/user/records' onclick='app.aclick(this)'><i class='icon-users'></i><span>Пользователи</span></a>
			</li>
			<li data-route='model/page'>
				<div class='icon fade'><a href='/admin/model/page/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/page/records' onclick='app.aclick(this)'><i class='icon-file6'></i><span>Страницы</span></a>
			</li>"
		else
			ret += "<li data-route='model/order/records'>
				<a href='/admin/model/order/records' onclick='app.aclick(this)'>
					<i class='icon-cart4'></i><span>Заказы</span>
				</a>
			</li>
			<li data-route='model/status'>
				<div class='icon fade'><a href='/admin/model/status/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/status/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы заказов</span></a>
			</li>
			<li data-route='model/packinglist'>
				<div class='icon fade'><a href='/admin/model/packinglist/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/packinglist/records' onclick='app.aclick(this)'><i class='icon-credit'></i><span>Список накладных</span></a>
			</li>
			<li data-route='model/extension'>
				<div class='icon fade'><a href='/admin/model/extension/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
				<a href='/admin/model/extension/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы товаров</span></a>
			</li>"
		app.menu.html ret + "<li><a rel='nofollow' data-method='delete' href='/users/sign_out'><i class='icon-exit'></i><span>Выход</span></a></li>"
	app.notify = $ '#notify'
	app.go app.pathname = window.location.pathname
$(document).ready ready