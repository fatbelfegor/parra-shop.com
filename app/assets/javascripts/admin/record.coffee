@record =
	checkField: (el) ->
		el = $ el
		div = el.parent()
		name = div.parents('.dropdown').data 'name'
		console.log name
		table = tables[name]
		switch el.data 'type'
			when 'text'
				type = 'text'
			else
				type = 'string'
		string = table.fields.string
		text = table.fields.text
		fields = table.fields[type]
		if div.hasClass 'checked'
			fields.splice fields.indexOf(div.removeClass('checked').next().html()), 1
		else
			fields.push div.addClass('checked').next().html()
		width = 100 / string.length
		ret = "<div><div>"
		for field in string
			ret += "<p>#{field}</p>"
		ret += "</div>"
		for field in text
			ret += "<div><p>#{field}</p></div>"
		$("[data-records-header=#{name}]").html ret + "</div></div>"
		$("[data-model=#{name}]").each ->
			el = $ @
			for rec in table.records
				if rec.record.id is el.data 'id'
					ret = ''
					for field in string
						ret += "<p style='width: #{width}%'>#{rec.record[field]}</p>"
					stringWrap = el.find('.string')
					stringWrap.html ret
					ret = ''
					for field in text
						ret += "<div class='text'>#{rec.record[field]}</div>" unless rec[field] is ''
					el.find('.text').remove()
					stringWrap.after ret
					break
	checkHasMany: (el) ->
		el = $ el
		div = el.parent()
		name = div.parents('.dropdown').data 'name'
		table = tables[name]
		show_has_many = table.show_has_many
		rel = div.next().html()
		for k, t of tables
			if t.pluralize is rel
				relTable = t
				sing = relTable.singularize
		if div.hasClass 'checked'
			div.removeClass 'checked'
			$("[data-model=#{name}]").each ->
				$(@).find("> .relations > [data-records=#{sing}]").removeClass 'active'
			show_has_many.splice show_has_many.indexOf(rel), 1
		else
			div.addClass 'checked'
			show_has_many.push rel
			data = where: {}
			data.has_self = true if relTable.has_self
			data.where["#{name}_id"] = []
			load = false
			$("[data-model=#{name}]").each ->
				relations = $(@).find "> .relations"
				relation = relations.find("> [data-records=#{sing}]").addClass 'active'
				if relations.length isnt 0 and relation.find('.model-name').length is 0
					load = true
					data.where["#{name}_id"].push relations.data 'parentId'
			if load
				$.ajax
					url: "/admin/model/#{sing}/get"
					type: 'POST'
					data: data
					dataType: 'json'
					success: (d) ->
						for rec, i in d.records
							push = record: rec
							push.children = d.children[i] if d.children
							tables[sing].records.push push
						$("[data-model=#{name}]").each ->
							record.refresh $(@).find "> .relations > [data-records=#{sing}]"
	refresh: (wrap) ->
		name = wrap.data 'records'
		table = tables[name]
		width = 100 / table.fields.string.length
		string = table.fields.string
		text = table.fields.text
		records = table.records
		ret = ''
		switch wrap.data 'wrap'
			when 'main'
				ret = "<div data-records-header='#{name}' class='header'><div><div>"
				for field in string
					ret += "<p>#{field}</p>"
				ret += "</div>"
				for field in text
					ret += "<div><p>#{field}</p></div>"
				ret += "</div></div>"
				if table.has_self
					records = records.filter (rec) -> !rec.record["#{name}_id"]
			when 'children'
				id = wrap.parent().data 'id'
				records = records.filter (rec) -> rec.record["#{name}_id"] is id
			when 'relation'
				if wrap.html() is ''
					ret = "<div class='model-name'>#{name}</div>"
					relations = wrap.parent()
					id = relations.data 'parentId'
					parent_model = relations.parent().data 'model'
					records = records.filter (rec) -> rec.record["#{parent_model}_id"] is id
				else
					records = []
		for rec in records
			children = table.has_self and rec.children
			ret += "<div data-model='#{name}' data-id='#{rec.record.id}' class='record-wrap'>"
			ret += "<div class='btn-children' onclick='record.children(this)'></div>" if children
			ret += "<div class='btn-destroy' onclick='record.destroy(this)'></div>
				<div class='btn-edit' onclick='record.edit.inline.open(this)'></div>
				<div class='record'><div class='around'></div><a onclick='app.aclick(this)' href='/admin/model/#{name}/edit/#{rec.record.id}' class='string'>"
			for field in string
				ret += "<p style='width: #{width}%'>#{rec.record[field]}</p>"
			ret += "</a>"
			for field in text
				ret += "<div class='text'>#{rec.record[field]}</div>"
			ret += "<form>
						<h3>Редактировать</h3>
						<br>"
			for field in table.columns
				val = rec.record[field.name]
				ret += "<label><p>#{field.name}:</p><input type='text' value='#{val}'></label>" unless field.name is 'id'
			ret += "<br><br><br>
						<div class='btn square red' onclick='record.edit.inline.close(this)'>Отменить</div>
						<div class='btn square green' onclick='record.edit.inline.save(this)'>Обновить</div>
					</form>
				</div>"
			ret += "<div data-parent-id='#{rec.record.id}' class='relations'>"
			for rel in table.has_many
				for k, t of tables
					if t.pluralize is rel
						ret += "<div class='relation' data-records='#{t.singularize}' data-wrap='relation'></div>"
			ret += "</div>"
			ret += "<div data-records='#{name}' data-wrap='children' data-parent-id='#{rec.record.id}' class='children'></div>" if children
			ret += "</div>"
		wrap.html ret
	children: (el) ->
		el = $ el
		parent = el.parent()
		childrenWrap = parent.find('> .children')
		if el.hasClass 'active'
			el.removeClass 'active'
			childrenWrap.removeClass 'active'
		else
			el.addClass 'active'
			childrenWrap.addClass 'active'
			record.loadChildren parent.data('model'), parent.data('id'), ->
				record.refresh childrenWrap
	edit:
		inline:
			close: (el) ->
				$(el).parents('.edit').removeClass 'edit'
			save: (el) ->
				$(el).parents('.edit').removeClass 'edit'
			open: (el) ->
				$(el).next().addClass 'edit'
	busy: false
	send: (elem) ->
		el = $ elem
		form = el.parent()
		form.find('textarea').each ->
			@.value = tinymce.get(@.id).getContent()
		act.form form, 'Запись создана', (id) ->
			serialize = form.serializeArray()
			name = form.data 'table'
			table = tables[name]
			r = {}
			for column in table.columns
				present = false
				if column.name is 'id'
					r.id = id
					present = true
				else
					for s in serialize
						if s.name is "record[#{column.name}]"
							value = s.value
							switch form.find("input[name='#{s.name}']").data 'type'
								when 'integer'
									value = parseInt value
							r[column.name] = value
							present = true
							break
			rec = record: r
			if table.has_self
				rec.children = 0
				if r["#{name}_id"]
					parent = form.find("#treebox_#{name}_id [data-val=#{r["#{name}_id"]}]")
					if parent.prev().length is 0
						for record in table.records
							if record.record.id is r["#{name}_id"]
								record.children = 1
								break
						table.full["#{name}_id"][r["#{name}_id"]] = true
						parent.before("<i class='icon-arrow-down2' onclick='record.treebox(this, \"#{name}\")'></i>").parent().after "<ul>
								<li><div><p onclick='treebox.pick(this)' data-val='#{id}'>#{r["name"]}</p></div></li>
							</ul>"
			table.records.push rec
	ask: (name, data, success, already) ->
		table = tables[name]
		load = true
		if table.full["all"]
			load = false
		else
			if table.has_self
				if table.full["#{name}_id"] and table.full["#{name}_id"][data.has_self]
					load = false
				else
					table.full["#{name}_id"] ||= {}
					table.full["#{name}_id"][data.has_self] = true
					data.where = {}
					if data.has_self is null
						data.has_self_null = true
					else
						data.where["#{name}_id"] = data.has_self
					data.has_self = true
		if load
			$.ajax
				url: "/admin/model/#{name}/get"
				type: 'POST'
				data: data
				dataType: 'json'
				success: (d) ->
					for rec, i in d.records
						push = record: rec
						push.children = d.children[i] if d.children
						table.records.push push
					success name
		else
			if already then already name else success name
	root: (name, success, already) ->
		@ask name, {has_self: null}, success, already
	loadChildren: (name, id, success, already) ->
		@ask name, {has_self: id}, success, already
	treebox: (el, name) ->
		treebox.toggle el
		el = $ el
		id = el.next().data 'val'
		ul = el.parent().next()
		record.loadChildren name, id, (name) ->
			records = []
			table = tables[name]
			for rec in table.records
				if rec.record["#{name}_id"] is id
					records.push rec
			ret = ''
			for rec in records
				ret += "<li>"
				if rec.children > 0
					ret += "<div><i class='icon-arrow-down2' onclick='record.treebox(this, \"#{name}\")'></i><p onclick='treebox.pick(this)' data-val='#{rec.record.id}'>#{rec.record.name}</p></div><ul></ul>"
				else
					ret += "<div><p onclick='treebox.pick(this)' data-val='#{rec.record.id}'>#{rec.record.name}</p></div>"
				ret += "</li>"
			ul.html ret
	destroy: (el, model, id) ->
		ask el, "Удалить запись?", (el) ->
			act.ajax "model/#{model}/#{id}/destroy", {}, "Запись удалена", ->
				$(el).parent().remove()