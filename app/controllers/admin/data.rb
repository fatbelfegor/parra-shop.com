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
						order_item: rec.order_items.map{|r|
							{
								record: r,
								belongs_to: {product: r.product}
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
						packinglistitem: rec.packinglistitems.map{|r| {record: r, belongs_to: {product: r.product}}}
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
		}
	},
	index: {
		product: lambda { |p|
			products = Product.all
			{
				product: {
					all: true,
					select: [:id, :name],
					records: products.select(:id, :name),
					ids: {size: products.map{|r| r.size_ids}}
				}
			}
		},
		category: lambda { |p|
			recs = Category.all
			{
				category: {
					all: true,
					select: [:id, :name, :position, :category_id],
					records: recs.select(:id, :name, :position, :category_id),
					ids: {
						subcategory: recs.map{|r| r.subcategory_ids},
						product: recs.map{|r| r.product_ids}
					}
				}
			}
		},
		extension: lambda { |p|
			{
				extension: {
					all: true,
					records: Extension.all
				}
			}
		},
		order: lambda { |p|
			recs = Order.all
			{
				order: {
					all: true,
					select: [:id, :created_at, :phone, :status_id],
					records: recs.select(:id, :created_at, :phone, :status_id).map{ |r|
						{
							record: r,
							belongs_to: {
								status: r.status
							},
							has_many: {
								order_item: r.order_items,
								virtproduct: r.virtproducts
							}
						}
					}
				}
			}
		},
		status: lambda { |p|
			{
				status: {
					records: Status.all
				}
			}
		},
		packinglist: lambda { |p|
			{
				packinglist: {
					records: Packinglist.all.map{|r| {record: r, has_many: {packinglistitem: r.packinglistitems}}}
				}
			}
		},
		banner: lambda { |p|
			{
				all: true,
				banner: {
					records: Banner.all
				}
			}
		},
		user: lambda { |p|
			recs = User.all
			{
				user: {
					all: true,
					select: [:id, :email, :prefix, :role],
					records: recs.select(:id, :email, :prefix, :role).map{ |r|
						{
							record: r,
							has_many: {
								user_log: r.user_logs
							}
						}
					}
				}
			}
		},
		page: lambda { |p|
			{
				page: {
					all: true,
					select: [:id, :url, :name],
					records: Page.select(:id, :url, :name)
				}
			}
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
		}
	}
}