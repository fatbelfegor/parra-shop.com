app.templates.form.subcategory_item =
	table: [
		{
			tr: [
				{
					without_tr: [1]
					td: [
						{
							header: "subcategory"
							field: "subcategory_id"
							belongs_to: "subcategory"
							treebox:
								data:
									subcategory:
										fields: ['name']
										pick: true
								pick:
									val: "id"
									header: "name"
						}
					]
				},
				{
					td: [
						{
							header: "Добавить изображение"
							image: 'image'
						}
					]
				},
				{
					td: [
						{
							attrs:
								height: "300px"
							text: 
								"Описание":
									field: "description"
									type: "editor"
						}
					]
				}
			]
		}
	]
	belongs_to: [
			{model: "subcategory"}
		]
	belongs_to_plain: "[\n\t{model: \"subcategory\"}\n]"