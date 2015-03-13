app.templates.index.category =
	table: [
		{
			tr: [
				{
					td: [
						{
							header: 'Переместить'
							attrs:
								class: 'sort-handler'
								style: 'width: 1px'
							html: "<div class='btn lightblue always'>[drag]</div>"
						},
						{
							header: 'Название'
							show: 'name'
						},
						{
							header: 'Создать подкатегорию'
							attrs:
								style: 'width: 1px'
							set: (rec) -> @html = "<a class='btn green always' onclick='app.aclick(this)' href='/admin/model/category/new?category_id=#{rec.id}'><i class='icon-plus'></i></a>"
						},
						{
							header: 'Редактировать'
							attrs:
								style: 'width: 1px'
							set: (rec) ->
								@html = "<a class='btn orange always' onclick='app.aclick(this)' href='/admin/model/#{param.model}/edit/#{rec.id}'><i class='icon-pencil3'></i></a>"
						},
						{
							header: "Удалить"
							attrs:
								style: 'width: 1px'
							html: "<div class='btn red always' onclick='functions.removeRecord(this)'><i class='icon-remove3'></i></div>"
						}
					]
				}
			]
		}
	]
	display: 'open-tree'
	sortable: 'tree'
	order: position: 'asc'