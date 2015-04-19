app.templates.index.category =
	where: category_id: null
	order: 'position'
	page: (recs) ->
		ret = header ['Перетащить', 'Подкатегории', 'Товары', ['Название', 'max'], ['Действия', false, 30]]
		window.productCopySizesTb = treebox.gen
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
		ret + records category recs
	after: ->
		sort parents: true
	ids: ['subcategory', 'product']
	functions:
		category: (recs) ->
			ret = ""
			tb = treebox.gen
				header: "Перенести товары"
				treeboxAttrs:
					style: 'width: 140px'
				headerAttrs:
					class: "btn blue"
					style: "width: 140px; padding: 5px 0 3px; height: 26px; border-color: transparent"
				mainListAttrs:
					style: 'left: -118px'
				data:
					subcategory:
						fields: ['name']
						pick: true
				pick:
					val: "id"
				pickAction: 'moveProducts(this)'
			recs.sort (a, b) ->
				if a.position > b.position
					return 1
				if a.position < b.position
					return -1
				0
			for id, rec of recs
				window.rec = rec
				html = drag() + btn_relation("Подкатегории", "subcategory") + btn_relation("Товары", "product") + show "name"
				if rec.product_ids.length
					html += td tb, attrs: style: 'width: 1px'
				html += new_child() + buttons()
				ret += group tr(html), relations:
					has_self_open: category
					close:
						subcategory:
							header: rel_header "Подкатегории", "subcategory"
							render: 'renderSubcategories'
							data:
								ids: ['product']
						product:
							header: rel_header "Товары", "product"
							render: 'renderProducts'
							data:
								ids: ['size']
			ret
		renderSubcategories: ->
			group tr([
				btn_relation "Товары", "product"
				show 'name'
				buttons()
			]), relations:
				close:
					product:
						header: rel_header "Товары", "product"
						render: 'renderProducts'
		renderProducts: ->
			group tr([
				btn_relation "Размеры", "size"
				show 'name'
				td productCopySizesTb, attrs: style: 'width: 1px'
				buttons()
			]), relations:
				close:
					size:
						header: rel_header "Размеры", "size"
						render: 'renderSizes'
						data:
							ids: ['color', 'option']
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
		moveProducts: (el) ->
			el.id = 'moveProducts'
			ask "Переместить товары?",
				ok:
					html: "Переместить"
					class: "blue"
				action: ->
					el = $('#moveProducts').attr 'id', ''
					treebox = el.parents '.treebox'
					category = db.category.records[treebox.parents('.group').eq(0).data 'id']
					product_ids = category.product_ids
					subcategory_id = el.data 'val'
					$.post "/admin/record/change",
						records:
							name: 'product'
							find: product_ids
						empty: 'category'
						change:
							category_id: null
							subcategory_id: subcategory_id
					, (res) ->
						for id, rec of db.product.records
							id = parseInt id
							if id in product_ids
								rec.category_ids = []
								rec.category_id = null
								rec.subcategory_id = subcategory_id
						category.product_ids = []
						subcategory = db.subcategory.records[subcategory_id]
						if subcategory.product_ids
							subcategory.product_ids = subcategory.product_ids.concat product_ids
						else subcategory.product_ids = product_ids
						app.route.page()
						notify 'Товары перенесены'
					, 'json'
				cancel: ->
					el = $('#moveProducts').attr 'id', ''