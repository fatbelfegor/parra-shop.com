app.templates.form.status =
	page: ->
		ret = "<table>" + tr(td field "Название", "name", validation: presence: true) + "</table>"
		title('статус заказа') + form ret