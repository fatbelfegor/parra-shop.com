app.templates.index.product =
	page: (recs) ->
		ret = header [['Размеры', 'min'], 'Название', ['Действия', '225px']]
		html = ""
		tb = treebox.gen
			header: "Скопировать размеры"
			treeboxAttrs:
				style: 'width: 165px'
			headerAttrs:
				class: "btn blue"
				style: "width: 165px; padding: 5px 0 3px; height: 26px; border-color: transparent"
			mainListAttrs:
				style: 'left: -118px; width: 367px'
			data:
				category:
					fields: ['name']
					has_self: true
					habtm:
						product:
							fields: ['name']
							pick: true
							group: 'Товары'
							has_many:
								size:
									fields: ['name']
									group: 'Размеры'
									pick: true
									has_many:
										color:
											fields: ['name']
											group: 'Цвета'
											has_many:
												texture:
													fields: ['name']
													group: 'Текстуры'
										option:
											fields: ['name']
											group: 'Опции'
			pickAction: 'productCopySizes(this)'
		for id, rec of recs
			window.rec = rec
			html += group tr([
				btn_relation "Размеры", "size"
				show "name"
				td tb, attrs: style: 'width: 1px'
				buttons()
			]), relations:
				close:
					size:
						header: rel_header "Размеры", "size"
						render: 'renderSizes'
						data:
							ids: ['color', 'option']
		ret += records html
		ret
	select: ['id', 'name']
	ids: 'size'
	functions:
		renderSizes: ->
			group tr([
				btn_relation "Цвета", "color"
				btn_relation "Опции", "option"
				show 'name', attrs: style: 'width: 25%'
				show 'scode', attrs: style: 'width: 25%'
				currency 'price', attrs: style: 'width: 25%'
				buttons()
			]), relations:
				close:
					color:
						header: rel_header "Цвета", "color"
						render: 'renderColors'
						data:
							ids: ['texture']
					option:
						header: rel_header "Опции", "option"
						render: 'renderOptions'
		renderColors: ->
			group tr([
				btn_relation "Текстуры", "texture"
				show 'name', attrs: style: 'width: 33%'
				show 'scode', attrs: style: 'width: 33%'
				currency 'price', attrs: style: 'width: 33%'
				buttons()
			]), relations:
				close:
					texture:
						header: rel_header "Текстуры", "texture"
						render: 'renderTextures'
		renderOptions: ->
			group tr [
				show 'name', attrs: style: 'width: 33%'
				show 'scode', attrs: style: 'width: 33%'
				currency 'price', attrs: style: 'width: 33%'
				buttons()
			]
		renderTextures: ->
			group tr [
				show 'name', attrs: style: 'width: 33%'
				show 'scode', attrs: style: 'width: 33%'
				currency 'price', attrs: style: 'width: 33%'
				buttons()
			]
		productCopySizes: (el) ->
			next = $(el).next()
			if next.data('model') is 'size'
				find = [next.data 'id']
			else find = next.data('relations').has_many.size
			product_id = next.parents('.group').data 'id'
			data = copy: [
				{
					name: 'size'
					set:
						product_id: product_id
					find: find
					has_many: [
						{
							name: 'color'
							has_many: [
								{
									name: 'texture'
								}
							]
						}
						{
							name: 'option'
						}
					]			
				}
			]
			$.post "/admin/record/copy", data, (params) ->
				save = (options) ->
					for n, p of options
						for r in p
							db[n].records[r.record.id] = r.record
							if r.has_many
								save r.has_many
				save params
				ids = []
				for r in params.size
					ids.push r.record.id
				if db.product.records[product_id].size_ids
					db.product.records[product_id].size_ids = db.product.records[product_id].size_ids.concat ids
				else db.product.records[product_id].size_ids = ids
				app.route.page()
				notify 'Размеры успешно скопированы'
			, 'json'