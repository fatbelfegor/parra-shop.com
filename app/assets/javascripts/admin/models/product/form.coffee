models.product_form =
	table: [
		{
			tr: [
				{
					td: [
						{
							header: 'Название'
							field: 'name'
						},
						{
							header: 'Код'
							field: 'scode'
						},
						{
							header: 'Артикул'
							field: 'article'
						}
					]
				},
				{
					td: [
						{
							header: 'Цена'
							field: 'price'
						},
						{
							header: 'Старая цена'
							field: 'old_price'
						},
						{
							header: 'Невидимый'
							checkbox: 'invisible'
						}
					]
				},
				{
					td: [
						{
							header: 'Seo Title'
							field: 'seo_title'
						},
						{
							header: 'Seo Description'
							field: 'seo_description'
						},
						{
							header: 'Seo Keywords'
							field: 'seo_keywords'
						}
					]
				},
				{
					td: [
						{
							images: true
							colspan: 3
						}
					]
				},
				{
					td: [
						{
							description: {
								'Описание': 'description',
								'Краткое описание': 'short_desc'
							}
							colspan: 3
						}
					]
				}
			]
		}
	]