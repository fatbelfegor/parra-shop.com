app.templates.index.user =
	page: (recs) ->
		ret = ""
		for rec in recs
			window.rec = rec
			ret += group tr([
				if rec.user_log_ids.length then btn_relation "Логи", "user_log" else ''
				show 'prefix', attrs: {width: '175px'}, format: replace_null: 'Без префикса'
				show 'email'
				show 'role', attrs: style: 'width: 175px'
				buttons()
			]), relations:
				close:
					user_log:
						header: "<p style='width: 100%'>Логи (<span class='relations-count'>#{window.rec['user_log_ids'].length}</span>)</p>"
						render: 'renderUserLogs'
		header([['Логи', 'min'], ['Префикс', '90px'], 'E-mail', ['Роль', '141px'], ['Действия', 'min']]) + records ret
	has_many: "user_log"
	ids: ["user_log"]
	functions:
		renderUserLogs: ->
			group tr [
				show "created_at", attrs: {style: 'width: 1px'}, format: date: "dd.MM.yyyy, hh:mm"
				show "action"
				destroy()
			]