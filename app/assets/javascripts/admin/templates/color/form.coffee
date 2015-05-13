app.templates.form.color =
	page: ->
		ret = "<table>"
		ret += tr td tb("Размер", 'size', data: {category: {fields: ['name'], has_self: true, habtm: product: {fields: ['name'], has_many: size: {fields: ['name'], pick: true}}}}), attrs: colspan: 3
		ret += tr image_field 'Добавить изображение', 'image', attrs: colspan: 3
		ret += tr [
			td field("Название", "name", {validation: presence: true}), attrs: {width: "33.3%"}
			td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {width: "33.3%"}
			td field "Цена", "price", {format: {decimal: "currency"}, validation: true}
		]
		ret += "</table>"
		texture = ""
		color = window.rec
		if window.rec
			recs = db.where 'texture', color_id: window.rec.id
			texture_visible = true if recs.length
			for rec in recs
				window.rec = rec
				texture += window.texture()
		window.rec = color
		ret += relation_add "Добавить текстуру", "texture_add"
		ret += relation 'texture', texture_visible, texture
		title('цвет') + form ret
	belongs_to: ["size"]
	has_many: ["texture"]
	functions:
		texture_add: (wrap) ->
			window.rec = false
			wrap.prepend texture()
			addFormCb()
		texture: ->
			ret = "<table>"
			ret += tr image_field 'Добавить изображение', 'image', attrs: colspan: 3
			ret += tr [
				td field("Название", "name", {validation: presence: true}), attrs: {width: "33.3%"}
				td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {width: "33.3%"}
				td field "Цена", "price", {format: {decimal: "currency"}, validation: true}
			]
			relation_record ret + "</table>"