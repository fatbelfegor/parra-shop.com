app.page = ->
	model = app.data.route.model
	ret = "<h1>Редактировать модель <b>#{model}</b></h1>
	<div class='content edit-model'>
		<form action='model/#{model.toLowerCase()}/update'>
			<div class='btn green dashed' onclick='act.send(this, \"Модель успешно обновлена\")'>Сохранить</div>
			<h2>Поля</h2>
			<table>
				<tr>
					<th colspan='3'>Действия</th>
					<th>Type</th>
					<th>Name</th>
					<th>Limit</th>
					<th>Precision</th>
					<th>Scale</th>
					<th>Default</th>
					<th>Index</th>
					<th>Null</th>
				</tr>"
	table = app.data.model[model].table
	indexes = table.indexes
	for c in table.columns
		for i in indexes
			if i.indexOf c.name > -1
				checked = ' checked'
		ret += '<tr>'
		if c.name != 'id'
			ret += "<td class='btn deepblue' onclick='model.column.rename(this)'>Переименовать</td>
					<td class='btn green' onclick='model.column.change(this)'>Изменить</td>
					<td class='btn red' onclick='model.column.remove(this)'>Удалить</td>"
		else
			ret += "<td></td><td></td><td></td>"
		ret += "<td class='type'>#{c.type}</td>
			<td class='name'>#{c.name}</td>
			<td class='limit'>#{c.limit || ''}</td>
			<td class='precision'>#{c.precision || ''}</td>
			<td class='scale'>#{c.scale || ''}</td>
			<td class='default'>#{c.default || ''}</td>
			<td><input type='checkbox' name='f[]index'#{checked}></td>
			<td><input class='null' type='checkbox' name='f[]null'#{c.null}></td></tr>"
	ret += "</table>
			<div class='rename'>
				<h2>Переименовать</h2>
			</div>
			<div class='change'>
				<h2>Изменить</h2>
			</div>
			<div class='remove'>
				<h2>Удалить</h2>
			</div>
			<h2>Добавить поля</h2>
			<table>
				<tr>
					<th>Type</th>
					<th>Name</th>
					<th>Limit</th>
					<th>Precision</th>
					<th>Scale</th>
					<th>Default</th>
					<th>Index</th>
					<th>Null</th>
					<th></th>
				</tr>
			</table>
			<div>
				<div class='btn green' onclick='model.column.add(this)'>Добавить поле</div>
				<div class='btn white' onclick='model.column.add(this, \"name\")'>Название</div>
				<div class='btn white' onclick='model.column.add(this, \"scode\")'>Код</div>
				<div class='btn white' onclick='model.column.add(this, \"description\")'>Описание</div>
				<div class='btn white' onclick='model.column.add(this, \"price\")'>Цена</div>
				<div class='btn white' onclick='model.column.add(this, \"image\")'>Изображение</div>
				<div class='btn white' onclick='model.column.add(this, \"seo\")'>Seo</div>
				<div class='btn white' onclick='model.column.add(this, \"parent_id\")'>Вложенность</div>
				<div class='btn white' onclick='model.column.add(this, \"position\")'>Позиция</div>
			</div>
			<div class='btn green dashed' onclick='act.send(this, \"Модель успешно обновлена\")'>Сохранить</div>
		</form>
	</div>"
	ret