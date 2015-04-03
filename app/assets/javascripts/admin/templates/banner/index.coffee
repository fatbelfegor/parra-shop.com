app.templates.index.banner =
	header: [['Изображение', '188px'], 'Ссылка', ['Действия', 'min']]
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								rowspan: "3"
								style: "height: 100px"
								class: "image"
							image:
								name: 'image'
						}
						{
							attrs:
								colspan: 3
						}
					]
				}
				{
					attrs:
						style: "height: 36px"
					td: [
						{
							show: "url"
						}
						{
							header: 'Редактировать'
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
				{
					td: [
						{
							attrs:
								colspan: 3
						}
					]
				}
			]
		}
	]