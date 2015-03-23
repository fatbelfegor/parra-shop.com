app.templates.form.category =
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								colspan: "6"
							header: "category"
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
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
								style: "width: 50%"
							header: "Название"
							field: "name"
							validation:
								presence: true
						},
						{
							attrs:
								colspan: "3"
							header: "Код"
							field: "scode"
							validation:
								uniq: true
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							header: "Наценка продавца"
							field: "commission"
						},
						{
							attrs:
								colspan: "3"
							header: "Наша наценка"
							field: "rate"
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "3"
							header: "SEO title"
							field: "seo_title"
						},
						{
							attrs:
								colspan: "3"
							header: "SEO keywords (через запятую)"
							field: "seo_keywords"
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "2"
							header: "Краткий url"
							field: "url"
						},
						{
							attrs:
								colspan: "2"
							header: "Мобильные url"
							field: "mobile_image_url"
						},
						{
							attrs:
								colspan: "2"
							header: "Показывать в мобильном клиенте"
							checkbox: "isMobile"
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "6"
							header: "Добавить изображение заголовка"
							image: 'header'
						}
					]
				},
				{
					td: [
						{
							attrs:
								colspan: "6"
							text: 
								"Описание":
									field: "description"
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