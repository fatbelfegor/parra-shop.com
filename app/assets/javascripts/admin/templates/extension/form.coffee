app.templates.form.extension =
	page: ->
		title('статус товара') + form btn_save() + "<table>" + tr field("Название", "name", validation: presence: true) + image_field 'Добавить изображение', 'image'