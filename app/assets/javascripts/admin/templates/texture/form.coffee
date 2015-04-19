app.templates.form.texture =
	page: ->
		ret = btn_save() + "<table>"
		ret += tr td tb("Цвет", 'color', data: {category: {fields: ['name'], has_self: true, habtm: product: {fields: ['name'], has_many: size: {fields: ['name'], has_many: color: {fields: ['name'], pick: true}}}}}), attrs: colspan: 3
		ret += tr image_field 'Добавить изображение', 'image', attrs: colspan: 3
		ret += tr [
			td field("Название", "name", {validation: presence: true}), attrs: {width: "33.3%"}
			td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {width: "33.3%"}
			td field "Цена", "price", {format: {decimal: "currency"}, validation: true}
		]
		ret += "</table>"
		ret += btn_save()
		title('текстуру') + form ret
	belongs_to: ["color"]