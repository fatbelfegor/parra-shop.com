app.templates.form.status =
	page: ->
		ret = btn_save() + "<table>" + tr(td field "Название", "name", validation: presence: true) + "</table>" + btn_save()
		title('статус заказа') + form ret