app.templates.index.size =
	header: [['Цвета', 'min'], ['Опции', 'min'], 'Название', ['Действия', 'min']]
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'color')"
							html: "<p>Цвета</p>"
						}
						{
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'option')"
							html: "<p>Опции</p>"
						}
						{
							show: "name"
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
			color:
				header: [
					name: "Цвета",
					(rec) -> "<a class='btn green square' onclick='app.aclick(this)' href='/admin/model/color/new?size_id=#{rec.id}'>Создать</a>"
				]
			option:
				header: [
					name: "Опции",
					(rec) -> "<a class='btn green square' onclick='app.aclick(this)' href='/admin/model/option/new?size_id=#{rec.id}'>Создать</a>"
				]