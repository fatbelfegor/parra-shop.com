class Admin::PackinglistController < Admin::AdminController
	def update
		data = {}
		for item in params[:items]
			update = {amount: item[:amount], price: item[:price]}
			id = item[:product_id]
			if id != ''
				product = Product.find_by_id id
				if product
					update[:product_id] = id
					update[:product_name_article] = product.scode
				end
			end
			Packinglistitem.find(item[:id]).update update
		end
		if params[:add_items]
			data[:item_ids] = []
			for item in params[:add_items]
				data[:item_ids] << Packinglistitem.create(packinglist_id: params[:packinglist_id], product_id: item[:product_id], product_name_article: Product.find_by_id(item[:product_id]).scode, amount: item[:amount], price: item[:price], name: item[:name]).id
			end
		end
		rend data: data
	end
	def create
		pack = Packinglist.create params.require(:pack).permit!
		product_ids = []
		product_scodes = []
		item_ids = []
		for i, item in params.require(:items).permit!
			product = Product.find_by_title(item[:product_name_article])
			if product.blank?
				product_ids << nil
				product_scodes << nil
			else
				product_ids << product.id
				product_scodes << product.scode
				item[:product_id] = product.id
				item[:product_name_article] = product.scode
			end
			item_ids << pack.packinglistitems.create(item).id
		end
		rend data: {pack_id: pack.id, item_ids: item_ids, product_ids: product_ids, product_scodes: product_scodes}
	end
end