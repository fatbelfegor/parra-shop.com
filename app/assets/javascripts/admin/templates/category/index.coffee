app.templates.index.category =
	header: ['Переместить', 'Подкатегории', 'Товары', ['Название', 'max'], ['Действия', false, 30]]
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								class: 'sort-handler btn lightblue always'
								style: 'width: 1px'
							html: "<i class='icon-cursor'></i>"
						}
						{
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'subcategory')"
							html: "<p>Подкатегории</p>"
						}
						{
							attrs:
								class: 'btn green'
								style: 'width: 1px'
								onclick: "functions.relationToggle(this, 'product')"
							html: "<p>Товары</p>"
						}
						{
							show: 'name'
						}
						{
							attrs:
								style: 'width: 1px'
							set: (rec) ->
								if rec.product_ids.length
									@continue = false
									tb =
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
										pickAction: 'functions.moveProducts(this)'
									@html = treebox.gen tb
								else
									@continue = true
						}
						{
							attrs:
								class: 'btn green always'
								style: 'width: 1px'
							set: (rec) -> @html = "<a onclick='app.aclick(this)' href='/admin/model/category/new?category_id=#{rec.id}'><i class='icon-plus'></i></a>"
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
	display: 'open-tree'
	sortable: 'tree'
	order: position: 'asc'
	relations:
		close:
			subcategory:
				header: [
					name: 'Подкатегории',
					(rec) -> "<a class='btn green square' onclick='app.aclick(this)' href='/admin/model/subcategory/new?category_id=#{rec.id}'>Создать</a>"
				]
			product:
				header: [
					name: "Товары",
					(rec) -> "<a class='btn green square' onclick='app.aclick(this)' href='/admin/model/product/new?category_id=#{rec.id}'>Создать</a>"
				]
	functions:
		moveProducts: (el) ->
			el.id = 'moveProducts'
			ask "Переместить товары?",
				ok:
					html: "Переместить"
					class: "blue"
				action: ->
					el = $('#moveProducts').attr 'id', ''
					treebox = el.parents '.treebox'
					category = models.category.collection[treebox.parents('.group').eq(0).data 'id']
					product_ids = category.product_ids
					subcategory_id = el.data 'val'
					$.post "/admin/record/change",
						records:
							name: 'product'
							find: product_ids
						change:
							category_ids: []
							category_id: null
							subcategory_id: el.data 'val'
					, (res) ->
						for id, rec of models.product.collection
							id = parseInt id
							if id in product_ids
								rec.category_ids = []
								rec.category_id = null
								rec.subcategory_id = subcategory_id
						category.product_ids = []
						subcategory = models.subcategory.collection[subcategory_id]
						if subcategory.product_ids
							subcategory.product_ids = subcategory.product_ids.concat product_ids
						else subcategory.product_ids = product_ids
						app.renderPage()
						notify 'Товары перенесены'
					, 'json'
				cancel: ->
					el = $('#moveProducts').attr 'id', ''