app.templates.form.color =
	table: [
		{
			tr: [
				{
					without_tr: [1]
					td: [
						{
							attrs:
								colspan: "3"
							header: "Размер"
							field: "size_id"
							belongs_to: "size"
							treebox:
								data:
									size:
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
				{
					td: [
						{
							attrs:
								colspan: "3"
							text: 
								"Описание":
									field: "description"
									type: "editor"
						}
					]
				}
				{
					td: [
						{
							attrs:
								colspan: 3
							relation_id: 3
						}
					]
				}
			]
		}
	]