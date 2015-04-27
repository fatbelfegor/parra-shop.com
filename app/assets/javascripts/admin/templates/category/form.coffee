app.templates.form.category =
	page: ->
		ret = btn_save() + "<table>"
		ret += tr td tb("Категория", 'category', data: {category: {fields: ['name'], pick: true, has_self: true}}), attrs: colspan: 6
		ret += tr [
			td field("Название", "name", {validation: presence: true}), attrs: {colspan: 3, width: "50%"}
			td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {colspan: 3, width: "50%"}
		]
		ret += tr [
			td field("Наценка продавца", "commission"), attrs: colspan: 3
			td field("Наша наценка", "rate"), attrs: colspan: 3
		]
		ret += tr [
			td field("SEO title", "seo_title"), attrs: colspan: 3
			td field("SEO keywords (через запятую)", "seo_keywords"), attrs: colspan: 3
		]
		ret += tr [
			td field("Краткий url", "url"), attrs: colspan: 2
			td field("Мобильные url", "mobile_image_url"), attrs: colspan: 2
			td field("Показывать в мобильном клиенте", "isMobile"), attrs: colspan: 2
		]
		ret += tr image_field 'Добавить изображение заголовка', 'header', attrs: colspan: 6
		ret += tr td images(), attrs: colspan: 6
		ret += tr td text("Описание": "description", "SEO текст": "seo_text", "SEO description": "seo_description": "textarea"), attrs: colspan: 6
		title('категорию') + form ret
	belongs_to: ["category"]