app.templates.index.subcategory =
	header: [['Товары', 'min'], 'Название', ['Действия', 'min']]
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'product')"
							html: "<p>Товары</p>"
						}
						{
							show: 'name'
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
			product:
				header: [
					name: "Товары",
					(rec) -> "<a class='btn green square' onclick='app.aclick(this)' href='/admin/model/product/new?subcategory_id=#{rec.id}'>Создать</a>"
				]