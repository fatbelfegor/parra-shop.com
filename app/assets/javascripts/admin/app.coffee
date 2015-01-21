#= require jquery
#= require jquery_ujs
#= require_self
#= require_tree .

@settings = template:
	form: model: {}
	index: model: {}

@app =
	routesSorted: {}
	data:
		route: {}
	aclick: (el, options) ->
		if window.history and history.pushState
			event.preventDefault()
			options ||= {}
			options.ref = @pathname
			app.go $(el).attr('href'), options
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
app.go = (url, options) ->
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
				app.backButton options.back, options.ref if options and options.back
		else
			params.success = (d) ->
				$.extend true, app.data, d
			params.dataType = 'json'
		$.ajax params
	else
		@yield.html route.page()
		route.after() if route.after
		app.backButton options.back, options.ref if options and options.back
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
				val.children = []
			else
				val.has_self = false
			val.show_has_many = []
			val.fields = {}
			tmpl_index = settings.template.index.model[key]
			if tmpl_index
				val.fields.string = tmpl_index.string or []
				val.fields.text = tmpl_index.text or []
			else
				tmpl_index = settings.template.index.common
				val.fields.string = tmpl_index.string.filter((c) -> val.columns.filter((s) -> s.name is c.name).length > 0) if tmpl_index.string
				val.fields.text = tmpl_index.text.filter((c) -> val.columns.filter((s) -> s.name is c).length > 0) if tmpl_index.text
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
				<a href='/admin/model'>
					<i class='icon-table2'></i>
					<span>Модели</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
				<ul>
					<li>
						<a href='/admin/model/new'>
							<i class='icon-plus-circle'></i>
							<span>Создать новую</span>
						</a>
					</li>
					<li>
						<a href='/admin/model/habtm'>
							<i class='icon-loop'></i>
							<span>Создать связь HABTM</span>
						</a>
					</li>"
		for n, table of tables
			name = table.name
			low = table.singularize
			ret += "<li><a href='/admin/model/#{low}'><i class='icon-stack'></i><span>#{word name}</span></a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
				<ul>
					<li><a href='/admin/model/#{low}/records'><i class='icon-menu2'></i><span>Все записи</span></a></li>
					<li><a href='/admin/model/#{low}/new' data-path='new'><i class='icon-quill2'></i><span>Добавить запись</span></a></li>
					<li><a href='/admin/model/#{low}/edit'><i class='icon-settings'></i><span>Редактировать модель</span></a></li>
					<li><p href='/admin/model/#{low}/destroy' onclick='ask(this, &quot;Вы действительно хотите удалить модель <b>#{low}</b>?&quot;, &quot;model.destroy(&#039;#{low}&#039;)&quot;)'><i class='icon-remove3'></i><span>Удалить модель</span></p></li>
				</ul>
			</li>"
		ret += "</ul>
			</div>
			<div>
				<a href='/admin/images'>
					<i class='icon-image'></i>
					<span>Изображения</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
			</div>
			<div>
				<a href='/admin/model/order/records'>
					<i class='icon-cart4'></i>
					<span>Заказы</span>
				</a>
			</div>
			<div>
				<a href='/admin/packinglist'>
					<i class='icon-credit'></i>
					<span>Список накладных</span>
				</a>
			</div>
			<div>
				<a href='/admin/controllers'>
					<i class='icon-sun'></i>
					<span>Контроллеры</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
				<ul>
					<li>
						<a href='/admin/controllers/new'>
							<i class='icon-plus-circle'></i>
							<span>Создать новый</span>
						</a>
					</li>"
		if app.data.controllers
			for con, hash of app.data.controllers
				ret += "<li>
						<a href='/admin/controllers/#{con}'>
							<i class='icon-cog'></i>
							<span>#{con}</span>
						</a>
					</li>"
		ret += "</ul>"
		ret += "</div>
			<div>
				<a href='/admin/components'>
					<i class='icon-share3'></i>
					<span>Компоненты</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
			</div>
			<div>
				<a href='/admin' data-path='templates'>
					<i class='icon-copy'></i>
					<span>Шаблоны</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
			</div>
			<div>
				<a href='/admin/components'>
					<i class='icon-database2'></i>
					<span>Базы данных</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
			</div>
			<div>
				<a href='/admin/settings'>
					<i class='icon-wrench2'></i>
					<span>Настройки</span>
				</a>
				<i class='icon-arrow-right11' onclick='$(this).prev().toggleClass(\"active\")'></i>
				<ul>
					<li>
						<a href='/admin/settings/template_index'>
							<i class='icon-puzzle4'></i>
							<span>Страница \"Все записи\"</span>
						</a>
					</li>
					<li>
						<a href='/admin/settings/template_form'>
							<i class='icon-puzzle4'></i>
							<span>Форма записи</span>
						</a>
					</li>
					<li>
						<a href='/admin/settings/localization'>
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
	$('a').click ->
		app.aclick(@)
$(document).ready ready