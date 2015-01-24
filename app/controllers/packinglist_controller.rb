class PackinglistController < ApplicationController
	def index
		if request.method == 'POST'
			require 'ox'
			xml = Ox.parse params[:file].read.force_encoding('UTF-8')
			list = xml.nodes[0].nodes[4].nodes[0].nodes
			# @ret = []
			list.each_with_index do |row, i|
				begin
					if row.nodes[0].nodes[0].nodes[0].nodes[0] == "Номер\rдокумента"
						nextRow = list[i + 1]
						login = current_user.email
						Packinglist.create(
							doc_number: nextRow.nodes[0].nodes[0].nodes[0],
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
							create[:name] = p.nodes[k].nodes[0].nodes.map{|n| n.nodes[0]}.join.gsub("\r", " ")
							create[:product_name_article] = p.nodes[k += 1].nodes[0].nodes[0]
							if p.nodes[k += 6].nodes.empty?
								create[:amount] = p.nodes[k += 1].nodes[0].nodes[0].to_i
							else
								create[:amount] = p.nodes[k].nodes[0].nodes[0].to_i
							end
							if p.nodes[k += 1].nodes.empty?
								create[:price] = p.nodes[k += 3].nodes[0].nodes[0].gsub(" ", "").gsub(",", ".").to_f / create[:amount]
							else
								create[:price] = p.nodes[k += 2].nodes[0].nodes[0].gsub(" ", "").gsub(",", ".").to_f / create[:amount]
							end
							product = Product.find_by_s_title(create[:product_name_article])
							create[:product_id] = product.id if product
							# @ret << create
							Packinglist.last.packinglistitems.create create
						end
					end
				rescue
				end
			end
			render text: @ret
		end	
	end
	def show
		@packinglist = Packinglist.find(params[:id])	
	end
	def update
		Packinglist.find(params[:id]).update packinglist_params
		items = params[:packinglistitems]
		for i in items
			Packinglistitem.find(i[:id]).update product_id: i[:product_id], product_name_article: i[:product_name_article], amount: i[:amount], price: i[:price]
		end
		redirect_to '/packinglist'
	end
	def destroy
		Packinglist.find(params[:id]).destroy
		redirect_to '/packinglist'
	end

private
	def packinglist_params
		params.require(:packinglist).permit(
			:doc_number,
			:date
		)
	end
end