Admin::Data = {
	edit: {
		product: lambda { |p|
			rec = Product.find(p[:id])
			{
				product: {
					record: rec,
					ids: {category: rec.category_ids},
					belongs_to: {
						extension: rec.extension,
						category: rec.category,
						subcategory: rec.subcategory
					},
					has_many: {
						image: rec.images
					}
				},
				category: {
					all: true,
					select: [:id, :name],
					records: Category.select(:id, :name)
				}
			}
		},
		extension: lambda { |p|
			{
				extension: {
					record: Extension.find(p[:id])
				}
			}
		},
		subcategory: lambda { |p|
			rec = Subcategory.find(p[:id])
			{
				subcategory: {
					record: rec,
					belongs_to: {
						category: rec.category
					},
					has_many: {
						subcategory_item: rec.subcategory_items
					}
				}
			}
		},
		size: lambda { |p|
			rec = Size.find(p[:id])
			{
				size: {
					record: rec,
					belongs_to: {
						product: rec.product
					},
					has_many: {
						color: rec.colors.map { |c| {record: c, has_many: { texture: c.textures } } },
						option: rec.options
					}
				}
			}
		},
		color: lambda { |p|
			rec = Color.find(p[:id])
			{
				color: {
					record: rec,
					belongs_to: {
						size: rec.size
					},
					has_many: {
						texture: rec.textures
					}
				}
			}
		},
		option: lambda { |p|
			rec = Option.find(p[:id])
			{
				option: {
					record: rec,
					belongs_to: {
						size: rec.size
					}
				}
			}
		},
		category: lambda { |p|
			rec = Category.find(p[:id])
			{
				category: {
					record: rec,
					belongs_to: {
						category: rec.category
					},
					has_many: {
						image: rec.images
					}
				}
			}
		},
		order: lambda { |p|
			rec = Order.find(p[:id])
			{
				order: {
					record: rec,
					belongs_to: {
						status: rec.status
					},
					has_many: {
						order_item: {
							records: rec.order_items,
							belongs_to: {
								product: rec.order_items.map{|r| r.product}
							}
						},
						virtproduct: rec.virtproducts
					}
				}
			}
		},
		status: lambda { |p|
			{
				status: {
					records: Status.find(p[:id])
				}
			}
		},
		packinglist: lambda { |p|
			rec = Packinglist.find(p[:id])
			{
				packinglist: {
					record: rec,
					has_many: {
						packinglistitem: {
							records: rec.packinglistitems,
							belongs_to: {
								product: {records: rec.packinglistitems.map{|r| r.product}}
							}
						}
					}
				}
			}
		},
		banner: lambda { |p|
			{
				banner: {
					record: Banner.find(p[:id])
				}
			}
		},
		page: lambda { |p|
			{
				page: {
					record: Page.find(p[:id])
				}
			}
		},
		user: lambda { |p|
			{
				user: {
					record: User.find(p[:id])
				}
			}
		}
	},
	index: {
		product: {
			limit: 50,
			count: true,
			order: :position,
			select: [:name, :position],
			ids: [:size]
		},
		category: {
			select: [:name, :position, :category_id],
			order: 'position',
			ids: [:subcategory, :product]
		},
		order: {
			order: 'created_at DESC',
			select: [:created_at, :phone, :status_id],
			belongs_to: [:status],
			has_many: [:order_item, :virtproduct]
		},
		packinglist: {
			ids: [:packinglistitem],
			has_many: [:packinglistitem]
		},
		user: {
			select: [:email, :prefix, :role],
			has_many: [:user_log]
		},
		page: {
			select: [:url, :name]
		}
	},
	new: {
		product: lambda { |p|
			{
				category: {
					all: true,
					select: [:id, :name],
					records: Category.select(:id, :name)
				}
			}
		},
		size: lambda { |p|
			if p[:product_id]
				{product: Product.find(p[:product_id])}
			end
		},
		color: lambda { |p|
			if p[:size_id]
				{size: Size.find(p[:size_id])}
			end
		},
		option: lambda { |p|
			if p[:size_id]
				{size: Size.find(p[:size_id])}
			end
		},
		texture: lambda { |p|
			if p[:color_id]
				{color: Color.find(p[:color_id])}
			end
		},
		category: lambda { |p|
			if p[:category_id]
				{category: Category.find(p[:category_id])}
			end
		},
		subcategory: lambda { |p|
			if p[:category_id]
				{category: Category.find(p[:category_id])}
			end
		}
	}
}