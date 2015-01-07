class Admin::PackinglistController < Admin::AdminController
	def index
		rend page: 'packinglist/index', data: {
			records: {
				'packinglist' => Packinglist.all.map{|p| {record: p}},
				'packinglistitem' => Packinglistitem.all.map{|p| {record: p}}
			}
		}
	end
	def show
		pack = Packinglist.find params[:id]
		rend page: 'packinglist/show', data: {
			records: {
				'packinglist' => [{record: pack}],
				'packinglistitem' => pack.packinglistitems.map{|p| {record: p}}
			}
		}
	end
	def update
		for item in params[:items]
			Packinglistitem.find(item[:id]).update amount: item[:amount], price: item[:price]
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
						date: Date.strptime(nextRow.nodes[1].nodes[0].nodes[0].split('-').map{|s| s = s.to_i}.join(' '), '%Y %m %d')
					)
				end
			rescue
			end
			begin
				if row.nodes[0].nodes[0].nodes[0] == '1' and list[i - 1].nodes[0].nodes[0].nodes[0] != '1'
					until list[i += 1].nodes[0].nodes.empty?
						p = list[i]
						if !p.nodes[2].nodes.blank?
							scodeCell = 2
						else
							scodeCell = 3
						end
						create = {}
						s_title = p.nodes[scodeCell].nodes[0].nodes[0]
						create[:name] = p.nodes[1].nodes[0].nodes.map{|n| n.nodes[0]}.join
						product = Product.find_by_s_title s_title
						if product.blank?
							create[:product_name_article] = s_title
						else
							create[:product_id] = product.id
						end
						amount = p.nodes[scodeCell + 1].nodes[0].nodes[0].to_i
						amount = 1 if amount == 0
						create[:amount] = amount
						create[:price] = p.nodes[scodeCell + 14].nodes[0].nodes[0].gsub(' ','').gsub(',','.').to_f / amount
						packinglistitems << Packinglist.last.packinglistitems.create(create)
					end
				end
			rescue
			end
		end
		rend data: {'packinglist' => Packinglist.all,
			'packinglistitem' => Packinglistitem.all}
	end
end