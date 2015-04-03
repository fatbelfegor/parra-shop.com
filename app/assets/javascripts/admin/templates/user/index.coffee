app.templates.index.user =
	header: [['Логи', 'min'], ['Префикс', '90px'], 'E-mail', ['Роль', '141px'], ['Действия', 'min']]
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'user_log')"
							html: "<p>Логи</p>"
							set: (rec) -> @continue = if rec.user_log_ids.length then false else true
						}
						{
							attrs:
								width: '175px'
							show: "prefix"
							format:
								replaceNull: "Без префикса"
						}
						{
							show: "email"
						}
						{
							attrs:
								width: '175px'
							show: "role"
						}
						{
							attrs:
								class: 'btn orange always'
								style: 'width: 1px'
							set: (rec, model) -> @html = "<a onclick='app.aclick(this)' href='/admin/model/#{model}/edit/#{rec.id}'><i class='icon-pencil3'></i></a>"
						}
						{
							attrs:
								class: 'btn red always'
								onclick: 'functions.removeRecord(this)'
								style: 'width: 1px'
							html: "<i class='icon-remove3'></i>"
						}
					]
				}
			]
		}
	]
	relations:
		close:
			user_log:
				header: [
					name: 'Логи'
				]