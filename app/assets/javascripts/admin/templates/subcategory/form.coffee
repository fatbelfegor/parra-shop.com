app.templates.form.subcategory =
	table: [
		{
			tr: [
				{
					td: [
						{
							header: "Категория"
							field: "category_id"
							belongs_to: "category"
							treebox:
								data:
									category:
										fields: ['name']
										pick: true
										has_self: true
								pick:
									val: "id"
									header: "name"
						}
					]
				}
				{
					td: [
						{
							header: "name"
							field: "name"
						}
					]
				}
				{
					td: [
						{
							text: 
								"description":
									field: "description"
									type: "editor"
						}
					]
				}
			]
		}
	]
	belongs_to: [
			{model: "category"}
		]
	belongs_to_plain: "[\n\t{model: \"category\"}\n]"
	has_many: [
			{model: "subcategory_item"}
		]