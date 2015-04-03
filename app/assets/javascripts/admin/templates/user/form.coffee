app.templates.form.user =
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								width: '33.3%'
							header: "Префикс"
							field: "prefix"
						}
						{
							attrs:
								width: '33.3%'
							header: "E-mail"
							field: "email"
							type: "email"
							validation:
								presence: true
								uniq: true
								email: true
						}
						{
							attrs:
								width: '33.3%'
							header: "Роль"
							field: "role"
						}
					]
				}
				{
					td: [
						{}
						{
							header: "Пароль"
							field: "password"
							type: "password"
							validation:
								minLength: 8
						}
						{}
					]
				}
			]
		}
	]
	beforeSave: ->
		pass = $ "[name='password']"
		pass.after "<input type='hidden' name='password_confirmation' value='#{pass.val()}'><input type='hidden' name='confirmed_at' value='#{new Date}'>"