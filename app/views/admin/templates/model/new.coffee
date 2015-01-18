app.page = ->
	dropdown = "<div class='dropdown' data-action='modelRelation' onclick='dropdown.toggle(this)'><input type='text' placeholder='Model' onkeyup='window.model.addReference.inputChange(this)'><i class='icon-arrow-right4 blue hidden' onclick='model.addReference.icon(this)'></i><div>"
	for n, table of tables
		dropdown += "<p onclick='dropdown.pick(this)'>#{table.name}</p>"
	dropdown += "</div></div>"
	ret = "<h1>Создать новую модель</h1>
	<div class='content'>
		<form action='model/create'>
			<div class='btn green dashed' onclick='model.create(this)'>Создать</div>
			<label class='big'><div>Название</div><input type='text' name='model' data-validate=['presence']><p class='error'></p></label>
			<br>
			<div class='nav-tabs'>
				<p onclick='openTab(this)' class='active'>Поля</p>
				<p onclick='openTab(this)'>belongs_to</p>
				<p onclick='openTab(this)'>has_many</p>
				<p onclick='openTab(this)'>has_one</p>
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
			ret += "<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='imageable'></div>Множество картинок</label>"
			break
	ret += "<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='acts_as_tree'></div>Принадлежит сама себе</label>
						<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='timestamps'></div>Timestamps</label>
					</div>
					<br>
				</div>
				<div class='association-wrap' data-type='belongs_to'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of tables
		ret += "<div class='btn deepblue' onclick='model.association(this, true)'>#{table.singularize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green dashed' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>
				<div class='association-wrap' data-type='has_many'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of tables
		ret += "<div class='btn deepblue' onclick='model.association(this, true)'>#{table.singularize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green dashed' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>
				<div class='association-wrap' data-type='has_one'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of tables
		ret += "<div class='btn deepblue' onclick='model.association(this, true)'>#{table.singularize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green dashed' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>
				<!--<div class='association-wrap' data-type='has_and_belongs_to_many'>
					<br>
					<div data-content='model-names' class='buttons-list'>"
	for n, table of tables
		ret += "<div class='btn deepblue' onclick='model.association(this, true)'>#{table.singularize}</div>"
	ret += "</div>
					<br>
					<div class='center-row insert'></div>
					<div class='btn green dashed' onclick='model.association(this)'>Добавить</div>
					<br>
				</div>-->
			</div>
			<div class='btn green dashed' onclick='model.create(this)'>Создать</div>
		</form>
	</div>"
	ret