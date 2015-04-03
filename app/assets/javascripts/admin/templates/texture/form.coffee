app.templates.form.texture =
	table: [
		{
			tr: [
				{
					without_tr: [1]
					td: [
						{
							attrs:
								colspan: "3"
							header: "Цвет"
							field: "color_id"
							belongs_to: "color"
							treebox:
								data:
									color:
										fields: ['name']
										pick: true
								pick:
									val: "id"
									header: "name"
						}
					]
				}
				{
					td: [
						{
							attrs:
								"width": "33.3%"
							header: "Название"
							field: "name"
							validation:
								presence: true
						},
						{
							attrs:
								"width": "33.3%"
							header: "Код"
							field: "scode"
							validation:
								presence: true
						},
						{
							attrs:
								"width": "33.3%"
							header: "Цена"
							field: "price"
							format:
								decimal: "currency"
						}
					]
				}
				{
					td: [
						{
							attrs:
								colspan: 3
							header: "Добавить изображение"
							image: 'image'
						}
					]
				}
			]
		}
	]