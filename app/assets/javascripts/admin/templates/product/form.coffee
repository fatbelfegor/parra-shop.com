app.templates.form.product =
	page: ->
		ret = "<table>"
		ret += tr td tb("Статус", 'extension', data: {extension: {fields: ['name'], pick: true}}), attrs: colspan: 3
		ret += tr td tb("Категория", 'category', data: {category: {fields: ['name'], pick: true, has_self: true}}), attrs: colspan: 3
		ret += tr td tb("Подкатегория", 'subcategory', data: {subcategory: {fields: ['name'], pick: true}}), attrs: colspan: 3
		ret += tr td habtm_checkboxes("Категории", "category", "name", 6), attrs: colspan: 3
		ret += tr [
			td field("Название", "name", {validation: presence: true}), attrs: {width: "33.3%"}
			td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {width: "33.3%"}
			td field("Артикул", "article"), attrs: {width: "33.3%"}
		]
		ret += tr [
			td field "Цена", "price", {format: {decimal: "currency"}, validation: true}
			td field "Старая цена", "old_price"
			td field "Позиция", "position"
		]
		ret += tr [
			td field "SEO title", "seo_title"
			td field "title", "title"
			td field "SEO keywords (через запятую)", "seo_keywords"
		]
		ret += tr [
			td checkbox "Отображать на главной странице", "main"
			td checkbox "Отображать на панели скидки", "action"
			td checkbox "Отображать на панели Хиты продаж", "best"
		]
		ret += tr [
			td checkbox "Сделать Невидимым", "invisible"
			td checkbox "Сделать Разделителем", "delemiter"
		]
		ret += tr td images(), attrs: colspan: 3
		ret += tr td text("Описание": "description", "Короткое описание": "shortdesk", "SEO текст": "seo_text", "SEO description": "seo_description": "textarea"), attrs: colspan: 3
		ret += "</table>"
		title('товар') + form ret
	belongs_to: ["extension", "subcategory"]
	has_many: "image"
	ids: "category"
	get: [{model: "category", select: ['id', 'name']}]