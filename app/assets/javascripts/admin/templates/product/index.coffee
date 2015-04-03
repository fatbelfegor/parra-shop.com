app.templates.index.product =
	header: [['Размеры', 'min'], 'Название', ['Действия', '225px']]
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'size')"
							html: "<p>Размеры</p>"
						}
						{
							show: "name"
						}
						{
							attrs:
								style: 'width: 1px'
							set: (rec) ->
								@continue = false
								tb =
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
									pick:
										val: "id"
									pickAction: 'functions.copySizes(this)'
								@html = treebox.gen tb
						}
						{
							attrs:
								class: 'btn orange always'
								style: 'width: 1px'
							set: (rec, model) -> @html = "<a onclick='app.aclick(this)' href='/admin/model/#{model}/edit/#{rec.id}'><i class='icon-pencil3'></i></a>"
						}
						{
							attrs:
								class: 'btn red always'
								onclick: 'functions.removeRecord(this)'
								style: 'width: 1px'
							html: "<i class='icon-remove3'></i>"
						}
					]
				}
			]
		}
	]
	relations:
		close:
			size:
				header: [
					name: "Размеры",
					(rec) -> "<a class='btn green square' onclick='app.aclick(this)' href='/admin/model/size/new?product_id=#{rec.id}'>Создать</a>"
				]
	functions:
		copySizes: (el) ->
			next = $(el).next()
			if next.data('model') is 'size'
				find = [next.data 'id']
			else find = el.next().data('relations').has_many.size
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
						model = models[n]
						for r in p
							model.collect r.record
							if r.has_many
								save r.has_many
				save params
				ids = []
				for r in params.size
					ids.push r.record.id
				if models.product.collection[product_id].size_ids
					models.product.collection[product_id].size_ids = models.product.collection[product_id].size_ids.concat ids
				else models.product.collection[product_id].size_ids = ids
				app.renderPage()
			, 'json'