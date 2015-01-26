class Admin::PackinglistController < Admin::AdminController
	def index
		@records = {
			'packinglist' => {records: Packinglist.all, full: {all: true}},
			'packinglistitem' => {records: Packinglistitem.all, full: {all: true}}
		}
		rend
	end
	def show
		@records = {
			'category' => {
				records: [],
				children: [],
				habtm: {products: []}
			},
			'product' => {
				records: Product.all,
				habtm: {categories: []}
			},
			'packinglist' => {
				records: [Packinglist.find(params[:id])],
				full: {id: params[:id]}
			},
			'packinglistitem' => {
				records: Packinglistitem.where(packinglist_id: params[:id]),
				full: {packinglist_id: params[:id]}
			}
		}
		for c in Category.all
			@records['category'][:records] << c
			@records['category'][:children] << Category.where(parent_id: c.id).count
			@records['category'][:habtm][:products] << c.product_ids
		end
		for p in Product.all
			@records['product'][:records] << p
			@records['product'][:habtm][:categories] << p.category_ids
		end
		rend
	end
	def update
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
			for item in params[:add_items]
				Packinglistitem.create packinglist_id: params[:packinglist_id], product_id: item[:product_id], product_name_article: Product.find_by_id(item[:product_id]).scode, amount: item[:amount], price: item[:price], name: item[:name]
			end
		end
		rend data: true
	end
	def upload
		require 'ox'
		xml = Ox.parse params[:file].read.force_encoding('UTF-8')
		list = xml.nodes[0].nodes[4].nodes[0].nodes
		packinglists = packinglistitems = []
		list.each_with_index do |row, i|
			begin
				if row.nodes[0].nodes[0].nodes[0].nodes[0] == "Номер\rдокумента"
					nextRow = list[i + 1]
					login = current_user.email
					packinglists << Packinglist.create(
						doc_number: nextRow.nodes[0].nodes[0].nodes[0],
						user: login,
						date: Date.strptime(nextRow.nodes[1].nodes[0].nodes[0].split('-').map{|s| s = s.to_i}.join(' '), '%Y %m %d')
					)
				end
			rescue
			end
			begin
				if row.nodes[0].nodes[0].nodes[0] == '1' and list[i - 1].nodes[0].nodes[0].nodes[0] != '1'
					while true
						p = list[i += 1]
						break if p.nodes[0].nodes.empty?
						create = {}
						k = 1
						if p.nodes[k].nodes[0].nodes.size == 1
							create[:name] = p.nodes[k].nodes[0].nodes[0]
						else
							create[:name] = p.nodes[k].nodes[0].nodes.map{|n| n.nodes[0]}.join.gsub("\r", " ")
						end
						create[:product_name_article] = p.nodes[k += 1].nodes[0].nodes[0]
						if p.nodes[k += 6].nodes.empty?
							create[:amount] = p.nodes[k += 1].nodes[0].nodes[0].to_i
						else
							create[:amount] = p.nodes[k].nodes[0].nodes[0].to_i
						end
						if p.nodes[k += 1].nodes.empty?
							if p.nodes[k + 3].nodes[0]
								create[:price] = p.nodes[k + 3].nodes[0].nodes[0].gsub(" ", "").gsub(",", ".").to_f / create[:amount]
							else
								create[:price] = p.nodes[k + 4].nodes[0].nodes[0].to_f
							end
						else
							create[:price] = p.nodes[k + 2].nodes[0].nodes[0].gsub(" ", "").gsub(",", ".").to_f / create[:amount]
						end
						product = Product.find_by_s_title(create[:product_name_article])
						create[:product_id] = product.id if product
						Packinglist.last.packinglistitems.create create
					end
				end
			rescue
			end
		end
		rend data: {'packinglist' => packinglists,
			'packinglistitem' => packinglistitems}
	end
end