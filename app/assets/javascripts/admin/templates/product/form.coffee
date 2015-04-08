app.templates.form.product =
	table: [
		{
			tr: [		   		
				{
					td: [
						{
							attrs:
								"colspan": "3"
							header: "Статус"
							field: "extension_id"
							belongs_to: "extension"
							treebox:
								data:
									extension:
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
								"colspan": "3"
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
							attrs:
								"colspan": "3"
							header: "Подкатегория"
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
				}
				{
					td: [
						{
							attrs:
								"colspan": "3"
							header: "Категории"
							habtm_checkboxes:
								model: "category"
								header: "name"
							row: 6
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
								uniq: true
						},
						{
							attrs:
								"width": "33.3%"
							header: "Артикул"
							field: "article"
						}
					]
				}
				{
					td: [
						{
							header: "Цена"
							field: "price"
							format:
								decimal: "currency"
							validation:
								presence: true
						},
						{
							header: "Старая цена"
							field: "old_price"
						},
						{
							header: "Позиция"
							field: "position"
						}
					]
				}
				{
					td: [
						{
							header: "SEO title"
							field: "seo_title"
						},
						{
							header: "title"
							field: "title"
						},
						{
							header: "SEO keywords (через запятую)"
							field: "seo_keywords"
						}
					]
				}
				{
					td: [
						{
							header: "Отображать на главной странице"
							checkbox: "main"
						},
						{
							header: "Отображать на панели скидки"
							checkbox: "action"
						},
						{
							header: "Отображать на панели Хиты продаж"
							checkbox: "best"
						}
					]
				},
				{
					td: [
						{
							header: "Сделать Невидимым"
							checkbox: "invisible"
						},
						{
							header: "Сделать Разделителем"
							checkbox: "delemiter"
						}
					]
				}
				{
					td: [
						{
							attrs:
								colspan: "3"
							images: true
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							text: 
								"Описание":
									field: "description"
									type: "editor"
								"Короткое описание":
									field: "shortdesk"
									type: "editor"
								"SEO текст":
									field: "seo_text"
									type: "editor"
								"SEO description":
									field: "seo_description"
									type: "textarea"
						}
					]
				}
			]
		}
	]
	belongs_to: [
			{model: "extension"}
			{model: "subcategory"}
		]
	preload: [
		{model: "category"}
	]
	with_id: [
		{
			param: {model: "image", where: {imageable_type: "Product"}}
			id: (id) -> @.param.where.imageable_id = id
		}
	]
	ids: [
		"category"
	]