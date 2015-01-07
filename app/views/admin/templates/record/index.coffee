app.page = ->
	model = app.data.route.model
	table = tables[model]
	ret = "<div id='record-index'>
		<div class='panel'>
			<div class='nav-tabs'>
				<p class='active'>Вид</p>
				<p>Поиск</p>
				<p>Ассоциации</p>
				<p>Действия</p>
			</div>
			<div class='tabs'>
				<div class='active'>
					<div class='dropdown' onclick='dropdown.toggle(this)' data-name='#{model}'>
						<p class='btn white square'><i class='icon-menu5'></i><span>Отображать поля</span><i class='icon-arrow-down2'></i></p>
						<div>"
	for column in table.columns
		name = column.name
		ret += "<label class='checkbox'><div"
		ret += " class='checked'" if name in table.fields.string
		ret += "><input type='checkbox' onchange='record.checkField(this)' data-type='#{column.type}'></div><span>#{name}</span></label>"
	ret += "</div>
					</div>
					<div class='dropdown submodels' data-name='#{model}'>
						<p class='btn white square' onclick='dropdown.toggle(this.parentNode)'><i class='icon-indent-increase'></i><span>Отображать связи</span><i class='icon-arrow-down2'></i></p>
						<div>"
	genHasMany = (has_many) ->
		ret = ''
		for rel in has_many
			for k, v of tables
				if v.pluralize is rel
					subtable = v
					submodel = v.singularize
					break
			ret += "<div class='model-wrap'>
				<label class='checkbox'>
					<div>
						<input type='checkbox' onchange='record.checkHasMany(this)'>
					</div>
					<span>#{rel}</span>
					<i class='icon-arrow-right3'></i>
				</label>
				<div class='model-options'>
					<div class='dropdown' data-name='#{submodel}'>
						<p class='btn white square' onclick='dropdown.toggle(this.parentNode)'>
							<i class='icon-menu5'></i>
							<span>Отображать поля</span>
							<i class='icon-arrow-down2'></i>
						</p>
						<div>"
			for column in subtable.columns
				name = column.name
				ret += "<label class='checkbox'><div"
				ret += " class='checked'" if name is 'name'
				ret += "><input type='checkbox' onchange='record.checkField(this)' data-type='#{column.type}'></div><span>#{name}</span></label>"
			ret += "</div>
					</div>"
			if subtable.has_many.length > 0
				ret += "<div class='dropdown submodels' data-name='#{submodel}'>
							<p class='btn white square' onclick='dropdown.toggle(this.parentNode)'>
								<i class='icon-indent-increase'></i>
								<span>Отображать связи</span>
								<i class='icon-arrow-down2'></i>
							</p>
							<div>"
				ret += genHasMany subtable.has_many
				ret += "</div></div>"
			ret += "</div>
			</div>"
		ret
	ret += genHasMany table.has_many
	ret += "</div>
					</div>
				</div>
			</div>
		</div>
		<div id='records' data-wrap='main' data-records='#{model}'>
		</div>
	<div>"
	ret
app.after = ->
	record.root app.data.route.model, ->
		record.refresh $ '#records'