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
end