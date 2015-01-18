app.page = ->
	model = app.data.route.model
	table = tables[model]
	ret = "<h1>Редактировать модель <b>#{model}</b></h1>
	<div class='content'>
		<form>
			<div class='btn green dashed' onclick='model.update(this)'>Редактировать</div>
			<div class='nav-tabs'>
				<p onclick='openTab(this)' class='active'>Добавить поля</p>
				<p onclick='openTab(this)'>Удалить поля</p>
			</div>
			<div class='tabs'>
				<div class='active add-column-wrap'>
					<table>
						<tr>
							<th>Type</th>
							<th>Name</th>
							<th>Limit</th>
							<th>Precision</th>
							<th>Scale</th>
							<th>Default</th>
							<th>Uniq</th>
							<th>Null</th>
							<th></th>
							<th></th>
						</tr>
					</table>
					<br>
					<div>
						<div class='btn green' onclick='model.column.add(this)'>Добавить поле</div>
						<div class='btn white' onclick='model.column.add(this, \"name\")'>Название</div>
						<div class='btn white' onclick='model.column.add(this, \"scode\")'>Код</div>
						<div class='btn white' onclick='model.column.add(this, \"article\")'>Артикул</div>
						<div class='btn white' onclick='model.column.add(this, \"short_desc\")'>Краткое описание</div>
						<div class='btn white' onclick='model.column.add(this, \"description\")'>Описание</div>
						<div class='btn white' onclick='model.column.add(this, \"price\")'>Цена</div>
						<div class='btn white' onclick='model.column.add(this, \"image\")'>Изображение</div>
						<div class='btn white' onclick='model.column.add(this, \"seo\")'>Seo</div>
						<div class='btn white' onclick='model.column.add(this, \"position\")'>Позиция</div>
					</div>
					<br>
					<div class='labels'>"
	for n of tables
		if n is 'image'
			if 'images' in table.has_many
				images = true
			ret += "<label class='checkbox'><div#{if images then " class='checked'" else ''}><input#{if images then " checked='checked'" else ''} onchange='checkbox(this)' type='checkbox' name='imageable'></div>Множество картинок</label>"
			break
	for column, i in table.columns
		timestamps = true if column.name is 'created_at' and table.columns[i + 1].name is 'updated_at'
	ret += "<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='acts_as_tree'></div>Принадлежит сама себе</label>
						<label class='checkbox'><div#{if timestamps then " class='checked'" else ''}><input#{if timestamps then " checked='checked'" else ''} name='timestamps' onchange='checkbox(this)' type='checkbox'></div>Timestamps</label>
					</div>
					<br>
				</div>
				<div>
					<table>
						<tr>
							<th>Type</th>
							<th>Name</th>
							<th>Limit</th>
							<th>Precision</th>
							<th>Scale</th>
							<th>Default</th>
							<th>Uniq</th>
							<th>Null</th>
							<th></th>
						</tr>"
	modelTable = app.data.model[model]
	for c in modelTable.columns
		uniq = false
		for i in modelTable.indexes
			uniq = true if c.name in i
		ret += "<tr>
			<td>#{c.type}</td>
			<td class='name' data-name='#{c.name}'>#{c.name}</td>
			<td>#{if c.limit then c.limit else ''}</td>
			<td>#{if c.precision then c.precision else ''}</td>
			<td>#{if c.scale then c.scale else ''}</td>
			<td>#{if c.default then c.default else ''}</td>
			<td><input type='checkbox' disabled #{if uniq then "checked='checked'" else ''}></td>
			<td><input type='checkbox' disabled #{if c.null then "checked='checked'" else ''}></td>
			<td class='btn red' onclick='model.column.remove(this)'>Удалить</td>
		</tr>"
	ret += "</table>
					<br>
					<h2>На удаление:</h2>
					<div class='to_remove'></div>
					<br>
				</div>
			</div>
			<div class='btn green dashed' onclick='model.update(this)'>Редактировать</div>
		</form>
	</div>"
	ret
model.column.remove = (el) ->
	tr = $(el).parent()
	name = tr.find('.name').data 'name'
	tr.parents('.active').find('.to_remove').append "<span class='btn red'><span>#{name}</span> <i class='icon-close' onclick='model.column.return(this)'></i><input type='hidden' name='remove[]' value='#{name}'></span>"
	tr.hide()
model.column.return = (el) ->
	el = $ el
	name = el.prev().html()
	el.parents('.active').find("[data-name=#{name}]").parent().show()
	el.parent().remove()