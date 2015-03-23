app.templates.index.category =
	table: [
		{
			tr: [
				{
					td: [
						{
							header: 'Переместить'
							attrs:
								class: 'sort-handler btn lightblue always'
								style: 'width: 1px'
							html: "<i class='icon-cursor'></i>"
						},
						{
							header: 'Подкатегории'
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'subcategory')"
							html: "<p>Подкатегории</p>"
						},
						{
							header: 'Товары'
							attrs:
								class: 'btn green'
								style: 'width: 1px'
							html: "<p>Товары</p>"
						},
						{
							header: 'Название'
							show: 'name'
						},
						{
							header: 'Создать подкатегорию'
							attrs:
								class: 'btn green always'
								style: 'width: 1px'
							set: (rec) -> @html = "<a onclick='app.aclick(this)' href='/admin/model/category/new?category_id=#{rec.id}'><i class='icon-plus'></i></a>"
						},
						{
							header: 'Редактировать'
							attrs:
								class: 'btn orange always'
								style: 'width: 1px'
							set: (rec) -> @html = "<a onclick='app.aclick(this)' href='/admin/model/#{param.model}/edit/#{rec.id}'><i class='icon-pencil3'></i></a>"
						},
						{
							header: "Удалить"
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
	display: 'open-tree'
	sortable: 'tree'
	order: position: 'asc'
	relations:
		close:
			subcategory:
				header: 'Подкатегории'