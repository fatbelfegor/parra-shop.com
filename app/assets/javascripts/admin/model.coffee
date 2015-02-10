@model =
	destroy: (model) ->
		act.post "model/#{model}/destroy", {}, ->
			notify "Модель <b>#{model}</b> успешно удалена"
			menu.remove "model/#{model}"
		dark.close()
	column:
		add: (el, name) ->
			params =
				name: ''
				type: 'String'
				precision: ''
				scale: ''
				null: true
			if name
				params.name = name
			switch name
				when 'name'
					params.null = false
				when 'scode'
					params.uniq = true
					params.null = false
				when 'description', 'short_desc', 'seo_description'
					params.type = 'Text'
				when 'price'
					params.type = 'Decimal'
					params.precision = 8
					params.scale = 2
					params.null = false
				when 'seo'
					@add el, 'seo_title'
					@add el, 'seo_description'
					@add el, 'seo_keywords'
					return
				when 'position'
					params.type = 'Integer'
			tr = "<tr class='field'>"
			tr += model.columnType params.type, 'addColumn[]type', 'td'
			tr += "<td>
						<input type='text' name='addColumn[]name' value='#{params.name}'>
					</td>
					<td class='min'>
						<input"
			tr += ' disabled' if params.type is 'Decimal'
			tr += " type='text' name='addColumn[]limit' data-type='limit' onkeypress='return event.charCode >= 48 && event.charCode <= 57'></td>
					<td class='min'>
						<input"
			tr += ' disabled' unless params.type is 'Decimal'
			tr += " value='#{params.precision}' type='text' name='addColumn[]precision' data-type='precision' onkeypress='return event.charCode >= 48 && event.charCode <= 57'>
					</td>
					<td class='min'>
						<input"
			tr += ' disabled' unless params.type is 'Decimal'
			tr += " value='#{params.scale}' type='text' name='addColumn[]scale' data-type='scale'  onkeypress='return event.charCode >= 48 && event.charCode <= 57'>
					</td>
					<td>
						<input type='text' name='addColumn[]default'>
					</td>
					<td>
						<input type='checkbox' name='addColumn[]uniq'"
			tr += " checked='checked'" if params.uniq
			tr += ">
					</td>
					<td>
						<input type='checkbox' name='addColumn[]null'"
			tr += " checked='checked'" if params.null
			tr += ">
					</td>
					<td class='btn red' onclick='rm(this)'>Удалить</td>
					<td class='btn blue sortable'>Переместить</td>
				</tr>"
			table = $(el).parents('.add-column-wrap').find 'table'
			table.append tr
			table.sortable
				items: "tr.field"
				handle: ".sortable"
		rename: (el) ->
			tr = $(el).parent()
			name = tr.find('.name').html()
			app.yield.find('.rename').show().append "<div class='row'>
					<p>Переименовать <b>\"#{name}\"</b></p>
					<input type='text' name='rename[]new'>
					<input type='hidden' name='rename[]old' value='#{name}'>
					<i class='icon-cancel-circle' onclick='rm(this)'></i>
				</div>"
		change: (el) ->
			tr = $(el).parent()
			name = tr.find('.name').html()
			type = tr.find('.type').html()
			precision = tr.find('.precision').html()
			scale = tr.find('.scale').html()
			limit = tr.find('.limit').html()
			default_column = tr.find('.default').html()
			null_column = tr.find('.null').get()[0].checked
			type = type[0].toUpperCase() + type[1..-1]
			html = "<div class='row'>
					<input type='hidden' name='change[]name' value='#{name}'>
					<input type='hidden' name='change[]old_type' value='#{type}'>
					<input type='hidden' name='change[]old_default' value='#{default_column}'>
					<input type='hidden' name='change[]old_null' value='#{null_column}'>
					<p>Изменить <b>\"#{name}\"</b></p>
					#{app.view.columnType 'name', 'change[]type'}"
			if type is 'Decimal'
				html += "<p>Precision:</p>
					<input type='hidden' name='change[]old_precision' value='#{precision}'>
					<input type='hidden' name='change[]old_scale' value='#{scale}'>
					<input type='text' name='change[]precision' value='#{precision}'>
					<p>Scale:</p>
					<input type='text' name='change[]scale' value='#{scale}'>"
			else
				html += "<p>Limit:</p>
					<input type='hidden' name='change[]old_limit' value='#{limit}'>
					<input type='text' name='change[]limit' value='#{limit}'>"
			html += "<p>Default:</p>
					<input type='text' name='change[]default' value='#{default_column}'>
					<p>Null: <input type='checkbox' name='change[]null'"
			html += " checked" if null_column
			html += "></p>
					<i class='icon-cancel-circle' onclick='rm(this)'></i>"
			html += "</div>"
			app.yield.find('.change').show().append html
		dropdown: (el) ->
			dropdown.pick el, valueWrap: (val) ->
				val + "<i class='icon-arrow-down2'></i>"
			, cb: (val) ->
				tr = $(el).parents 'tr'
				tr.find('[data-type]').prop 'disabled', true
				if val in ['Binary', 'Integer', 'String', 'Text']
					tr.find("[data-type='limit']").prop 'disabled', false
				else if val is 'Decimal'
					tr.find("[data-type='precision'], [data-type='scale']").prop 'disabled', false
	underscore: (str) ->
		str.split(/(?=[A-Z])/).join('_').toLowerCase()
	association: (el, name) ->
		el = $ el
		wrap = el.parents('.association-wrap')
		ret = "<label class='row'>
			<input type='text' name='#{wrap.data 'type'}[]name'"
		ret += " value='#{el.html()}'" if name
		ret += ">
			<i class='icon-cancel-circle' onclick='rm(this)'></i>
		</label>"
		wrap.find('.insert').append ret
	columnType: (type, name, tag) ->
		tag ||= 'div'
		ret = "<#{tag} class='dropdown' onclick='dropdown.toggle(this)'><p>#{type}<i class='icon-arrow-down2'></i></p><div>"
		for n in ['Binary', 'Boolean', 'Date', 'Datetime', 'Decimal', 'Float', 'Integer', 'Primary_key', 'String', 'Text', 'Time', 'Timestamp']
			ret += "<p"
			ret += " class=active" if type is n
			ret += " onclick='model.column.dropdown(this)'>#{n}</p>"
		ret + "</div><input type='hidden' name='#{name}' value='#{type}'></#{tag}>"