app.templates.form.size =
	page: ->
		ret = "<table>"
		ret += tr td tb("Товар", 'product', data: {category: {fields: ['name'], has_self: true, habtm: product: {fields: ['name'], pick: true}}}), attrs: colspan: 3
		ret += tr [
			td field("Название", "name", {validation: presence: true}), attrs: {width: "33.3%"}
			td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {width: "33.3%"}
			td field "Цена", "price", {format: {decimal: "currency"}, validation: true}
		]
		ret += "</table>"
		color = ""
		option = ""
		size = window.rec
		if window.rec
			recs = db.where 'color', size_id: param.id
			color_visible = true if recs.length
			for rec in recs
				window.rec = rec
				color += window.color()
			recs = db.where 'option', size_id: param.id
			option_visible = true if recs.length
			for rec in recs
				window.rec = rec
				option += window.option()
		window.rec = size
		ret += relation_add "Добавить цвет", "color_add"
		ret += relation 'color', color_visible, color
		ret += '<br>' + relation_add "Добавить опцию", "option_add"
		ret += relation 'option', option_visible, option
		title('размер') + form ret
	belongs_to: ["product"]
	has_many: [
		{model: "color", has_many: "texture"}
		{model: "option"}
	]
	functions:
		color_add: (wrap) ->
			window.rec = false
			wrap.prepend color()
			addFormCb()
		color: ->
			ret = "<table>"
			ret += tr image_field 'Добавить изображение', 'image', attrs: colspan: 3
			ret += tr [
				td field("Название", "name", {validation: presence: true}), attrs: {width: "33.3%"}
				td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {width: "33.3%"}
				td field "Цена", "price", {format: {decimal: "currency"}, validation: true}
			]
			ret += tr td text('Описание': 'description'), attrs: colspan: 3
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
			relation_record ret + relation('texture', texture_visible, texture, attrs: style: "margin: 20px 20px 10px") + '<br>'
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
		option_add: (wrap) ->
			window.rec = false
			wrap.prepend option()
			addFormCb()
		option: ->
			ret = "<table>"
			ret += tr [
				td field("Название", "name", {validation: presence: true}), attrs: {width: "33.3%"}
				td field("Код", "scode", {validation: {presence: true, uniq: true}}), attrs: {width: "33.3%"}
				td field "Цена", "price", {format: {decimal: "currency"}, validation: true}
			]
			relation_record ret + "</table>"