app.templates.form.user =
	page: ->
		ret = "<table>"
		ret += tr [
			td field("Префикс", "prefix", format: not_null: true), attrs: {width: "33.3%", colspan: 2}
			td field("E-mail", "email", validation: {presence: true, uniq: true}), attrs: {width: "33.3%", colspan: 2}
			td field("Роль", "role", format: not_null: true), attrs: {width: "33.3%", colspan: 2}
		]
		if window.rec
			ret += tr td('', attrs: colspan: 2) + td(field("Изменить пароль", "password", {type: 'password', validation: {custom: 'change_pass'}, val_cb: -> ''}), attrs: colspan: 2)
		else
			ret += tr [
				td field('Пароль', 'password', {type: 'password', validation: {minLength: 8}}), attrs: colspan: 3
				td field('Подтверждение пароля', 'password_confirmation', {type: 'password', validation: {custom: 'password_confirmation'}}), attrs: colspan: 3
			]
		ret += "</table>"
		title('пользователь') + form ret
	beforeSave: ->
		if window.rec
			pass = $ "[name='password']"
			if pass.val() is ''
				pass.data 'ignore', true
			else
				pass.data 'ignore', false
				conf = $("[name='password_confirmation']")
				if conf.length
					conf.val pass.val()
				else pass.after "<input type='hidden' name='password_confirmation' value='#{pass.val()}'><input type='hidden' name='confirmed_at' value='#{new Date}'>"
		else
			$("[name='password_confirmation']").after "<input type='hidden' name='confirmed_at' value='#{new Date}'>" unless $("[name='confirmed_at']").length
	functions:
		password_confirmation: (val) ->
			pass = $ "[name='password']"
			ret = ok: true, msg: 'Пароли не совпадают'
			ret.ok = false unless pass.val() is val
			ret
		change_pass: (val) ->
			ret = ok: true, msg: "Значение должно содержать минимум 8 знаков"
			ret.ok = false if val.length and val.length < 8
			ret