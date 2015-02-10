@localization = 
	save: (el) ->
		ret = "settings.localization ="
		$(el).parent().find('.row').each ->
			row = $ @
			from = row.find("[name='in']").val()
			to = row.find("[name='out']").val()
			if from isnt '' and to isnt ''
				ret += "\n\t#{from}: \"#{to}\""
			act.sendData "write", file: ret, path: "app/assets/javascripts/admin/settings/localization.coffee", "Локализация обновлена"
	enter: (el) ->
		@add $(el).find('.blue')[0]
		false
	add: (el) ->
		$(el).next().next().after @row()
	row: (k, v) ->
		"<div class='row'>
			<input type='text' name='in' value='#{if k then k else ''}'>
			<p><i class='icon-arrow-right12'></i></p>
			<input type='text' name='out' value='#{if v then v else ''}'>
			<p class='cancel' onclick='rm(this)'><i class='icon-close'></i></p>
		</div>"
app.page = ->
	ret = "<h1>Локализация</h1>
	<div class='content'>
		<form onsubmit='return localization.enter(this)'>
			<div class='btn green' onclick='localization.save(this)'>Сохранить</div>
			<br>
			<div class='btn blue' onclick='localization.add(this)'>Добавить (Enter)</div>
			<br>
			<br>
			#{localization.row()}"
	ret += localization.row k, v for k, v of settings.localization if settings.localization?
	ret += "<br>
			<div class='btn green' onclick='localization.save(this)'>Сохранить</div>
			<input type='submit' class='hide'>
		</form>
	</div>"
	ret