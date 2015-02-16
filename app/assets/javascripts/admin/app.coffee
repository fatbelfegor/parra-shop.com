#= require jquery
#= require jquery_ujs
#= require_self
#= require_tree .

@models = {}
@params = {}

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
		'model/new': {}
		'model/habtm': {}
		'model/:model/edit': {}
		'model/:model': {}
		'model/:model/new': {}
		'model/:model/records': {}
		'404': ->
			"<h1>404</h1>
			<div class='content'><br><br><br><br>Такой страницы нет, может скоро будет.<br><br><br><br></div>"
		'welcome': {}
		'components': {}
		'controllers': data: ['controllers']
		'controllers/:contr': data: ['controllers/:controller/code']
		'settings/localization': {}
		'settings/template_form': {}
		'settings/template_index': {}
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
	@route = @routes[routeArray.join '/']
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
	if @menu
		@menu.find('.current').removeClass 'current'
		@menu.find('.active').removeClass 'active'
		@menu.find("[href='#{@pathname}']").addClass 'current'
		url = "/admin"
		for part in @pathArray
			url += "/#{part}"
			@menu.find("[href='#{url}']").addClass 'active'
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
	if app.preload
		record.ask app.preload(), cb
		app.preload = null
	else cb()
ready = ->
	if data?
		$.extend true, app.data, data()
		for key, val of tables
			if val.pluralize in val.has_many
				val.has_many = val.has_many.filter (word) -> word isnt val.pluralize
				val.has_self = true
				val.children ||= []
			else
				val.has_self = false
	app.yield = $ '#yield'
	if !app.menu and tables
		app.menu = $ '#menu'
		ret = "<div>
					<a href='/'>
						<i class='icon-home4'></i>
						<span>На главную</span>
					</a>
				</div>
				<div>
				<a href='/admin/model' onclick='app.aclick(this)'>
					<i class='icon-table2'></i>
					<span>Модели</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
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
		for n, table of tables
			name = table.name
			low = table.singularize
			ret += "<li><a href='/admin/model/#{low}' onclick='app.aclick(this)'><i class='icon-stack'></i><span>#{word name}</span></a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
				<ul>
					<li><a href='/admin/model/#{low}/records' onclick='app.aclick(this)'><i class='icon-menu2'></i><span>Все записи</span></a></li>
					<li><a href='/admin/model/#{low}/new' onclick='app.aclick(this)'><i class='icon-quill2'></i><span>Добавить запись</span></a></li>
					<li><a href='/admin/model/#{low}/edit' onclick='app.aclick(this)'><i class='icon-settings'></i><span>Редактировать модель</span></a></li>
					<li><p href='/admin/model/#{low}/destroy' onclick='ask(this, &quot;Вы действительно хотите удалить модель <b>#{low}</b>?&quot;, &quot;model.destroy(&#039;#{low}&#039;)&quot;)'><i class='icon-remove3'></i><span>Удалить модель</span></p></li>
				</ul>
			</li>"
		ret += "</ul>
			</div>
			<div>
				<a href='/admin/images' onclick='app.aclick(this)'>
					<i class='icon-image'></i>
					<span>Изображения</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
			</div>
			<div>
				<a href='/admin/model/order/records' onclick='app.aclick(this)'>
					<i class='icon-cart4'></i>
					<span>Заказы</span>
				</a>
			</div>
			<div>
				<a href='/admin/packinglist' onclick='app.aclick(this)'>
					<i class='icon-credit'></i>
					<span>Список накладных</span>
				</a>
			</div>
			<div>
				<a href='/admin/controllers' onclick='app.aclick(this)'>
					<i class='icon-sun'></i>
					<span>Контроллеры</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
				<ul>
					<li>
						<a href='/admin/controllers/new' onclick='app.aclick(this)'>
							<i class='icon-plus-circle'></i>
							<span>Создать новый</span>
						</a>
					</li>"
		if app.data.controllers
			for con, hash of app.data.controllers
				ret += "<li>
						<a href='/admin/controllers/#{con}' onclick='app.aclick(this)'>
							<i class='icon-cog'></i>
							<span>#{con}</span>
						</a>
					</li>"
		ret += "</ul>"
		ret += "</div>
			<div>
				<a href='/admin/components' onclick='app.aclick(this)'>
					<i class='icon-share3'></i>
					<span>Компоненты</span>
				</a>
			</div>
			<div>
				<a href='/admin' onclick='app.aclick(this)'>
					<i class='icon-copy'></i>
					<span>Шаблоны</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
			</div>
			<div>
				<a href='/admin/components' onclick='app.aclick(this)'>
					<i class='icon-database2'></i>
					<span>Базы данных</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
			</div>
			<div>
				<a href='/admin/settings' onclick='app.aclick(this)'>
					<i class='icon-wrench2'></i>
					<span>Настройки</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
				<ul>
					<li>
						<a href='/admin/settings/template_index' onclick='app.aclick(this)'>
							<i class='icon-puzzle4'></i>
							<span>Страница \"Все записи\"</span>
						</a>
					</li>
					<li>
						<a href='/admin/settings/template_form' onclick='app.aclick(this)'>
							<i class='icon-puzzle4'></i>
							<span>Форма записи</span>
						</a>
					</li>
					<li>
						<a href='/admin/settings/localization' onclick='app.aclick(this)'>
							<i class='icon-flag'></i>
							<span>Локализация</span>
						</a>
					</li>
				</ul>
			</div>
			<div>
				<a href='/users/sing_out'>
					<i class='icon-exit'></i>
					<span>Выход</span>
				</a>
			</div>"
		app.menu.html ret
	app.notify = $ '#notify'
	app.go app.pathname = window.location.pathname
$(document).ready ready