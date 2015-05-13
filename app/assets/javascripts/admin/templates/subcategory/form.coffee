app.templates.form.subcategory =
	page: ->
		ret = "<table>"
		ret += tr td tb("Категория", 'category', data: {category: {fields: ['name'], pick: true, has_self: true}}), attrs: colspan: 3
		ret += tr td field "Название", "name"
		ret += tr td text "Описание": "description"
		ret += "</table>"
		if window.rec
			relation_visible = true
		ret += relation_add "Добавить картинку с описанием", "subcategory_item_add"
		subcategory_item = ""
		ret += relation 'subcategory_item', relation_visible, subcategory_item
		title('подкатегория') + form ret
	belongs_to: "category"
	has_many: "subcategory_item"
	functions:
		subcategory_item_add: (wrap) ->
			window.rec = false
			wrap.prepend subcategory_item()
			addFormCb()
		subcategory_item: ->
			ret = "<table>"
			ret += tr image_field 'Добавить изображение', 'image'
			ret += tr td text 'Описание': 'description'
			relation_record ret + "</table>"