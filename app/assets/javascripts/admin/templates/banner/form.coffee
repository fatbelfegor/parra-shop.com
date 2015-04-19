app.templates.form.banner =
	page: ->
		title('баннер') + form btn_save() + "<table>" + tr field("url", "url") + image_field('Добавить изображение', 'image') + "</table>"