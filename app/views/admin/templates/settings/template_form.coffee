app.page = ->
	ret = "<h1 class='title'>Вид страницы типа \"Новая запись\"</h1>
	<div class='content'>
		<br>"
	ret += "<div class='nav-tabs'>
		<p onclick='openTab(this)' class='active'>Общий вид</p>"
	for n of tables
		ret += "<p onclick='openTab(this)' class='capitalize'>#{n}</p>"
	ret += "</div><div class='tabs'>
		<div class='active'>
			<div class='btn green dashed' onclick='template.save(this, \"common\", true)'>Сохранить</div>
			<label class='group tags'>
				<p>Заглавия</p>
				<div>
					<form onsubmit='return tag.add(this)' data-name='headers'>"
	template = settings.template.form.common
	for name in template.headers
		ret += "<div><i class='icon-close' onclick='rm(this)'></i><p data-val='#{name}'>#{word name}</p></div>"
	ret += "<input type='text'>
						<input type='submit' class='hidden'>
					</form>
				</div>
			</label>
			<br>
			<label class='group tags red'>
				<p>Не отображать</p>
				<div>
					<form onsubmit='return tag.add(this)' data-name='hidden'>"
	for name in template.hidden
		ret += "<div><i class='icon-close' onclick='rm(this)'></i><p data-val='#{name}'>#{word name}</p></div>"
	ret += "<input type='text'>
						<input type='submit' class='hidden'>
					</form>
				</div>
			</label>
			</div>"
	for k, table of tables
		ret += "<div>
				<div class='btn green dashed' onclick='template.save(this, \"#{k}\", false)'>Сохранить</div>
				<label class='group tags'>
					<p>Заглавия</p>
					<div>
						<form onsubmit='return tag.add(this)' data-name='headers'>"
		template = settings.template.form.model[k]
		template ||= {headers: [], hidden: settings.template.form.common.hidden}
		ret += "<div><i class='icon-close' onclick='rm(this)'></i><p data-val='#{c.name}'>#{word c.name}</p></div>" for name in template.headers
		ret += "<input type='text'>
							<input type='submit' class='hidden'>
						</form>
					</div>
				</label>
			<br>
			<div>
				<div class='tag-container green'>
					<h2>Отображаемые поля</h2>
					<div class='fields-sortable'>"
		ret += "<p data-val='#{c.name}'>#{word c.name}</p>" for c in (table.columns.filter (c) -> c.name not in template.hidden)
		ret += "</div></div>
			</div>
			<br>
			<div>
				<div class='tag-container red' data-name='hidden'>
					<h2>Неотображаемые поля</h2>
					<div class='fields-sortable'>"
		ret += "<p data-val='#{name}'>#{word name}</p>" for name in template.hidden
		ret += "</div></div>
			</div>
		</div>"
	ret += "</div>
		<br>
	</div>"
	ret
@template = 
	save: (el, name, common) ->
		div = $(el).parent()
		data = {}
		data.path = "app/assets/javascripts/admin/settings/template_form_#{if common then "" else "model_"}#{name}.coffee"
		headers = []
		$(div).find('[data-name=headers] > div p').each ->
			headers.push "'#{$(@).data 'val'}'"
		hidden = []
		$(div).find('[data-name=hidden] > div p').each ->
			hidden.push "'#{$(@).data 'val'}'"
		data.file = "@settings.template.form.#{if common then "" else "model."}#{name} =\n\theaders: [#{headers.join ','}]\n\thidden: [#{hidden.join ','}]"
		act.sendData "write", data, "Вид страницы обновлен"
app.after = ->
	$('.fields-sortable').sortable
		connectWith: ".fields-sortable"