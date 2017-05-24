namespace :random do
	task stocks: :environment do
		stock_ids = Stock.pluck :id
		Product.find_each do |p|
			p.update stock_id: stock_ids.sample
		end
	end
end
