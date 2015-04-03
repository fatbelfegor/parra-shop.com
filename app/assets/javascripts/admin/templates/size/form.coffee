app.templates.form.size =
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								colspan: "3"
							header: "Товар"
							field: "product_id"
							belongs_to: "product"
							treebox:
								data:
									product:
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
							relation_id: 1
						}
					]
				}
				{
					td: [
						{
							attrs:
								colspan: 3
							relation_id: 2
						}
					]
				}
			]
		}
	]
	belongs_to: [
		{model: "category"}
	]
	has_many: [
		{model: "color", has_many: {model: "texture"}}
		{model: "option"}
	]
	relations: [
		{
			model: "color"
			header: "Цвета"
			addBtn: "Добавить"
			without_tr: 1
			relation_id: 1
			relations: [
				{
					model: "texture"
					header: "Текстуры"
					addBtn: "Добавить"
					without_tr: 1
					relation_id: 3
				}
			]
		}
		{
			model: "option"
			header: "Опции"
			addBtn: "Добавить"
			without_tr: 1
			relation_id: 2
		}
	]