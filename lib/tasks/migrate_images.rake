namespace :migrate do
	task product_images: :environment do
		root = Rails.root.join('public').to_s
		Product.all.each do |p|
			if images = p.images
				images = images.split ','
				images.each do |image_path|
					path = root + image_path
					if File.exists? path
						i = p.product_images.new
						i.image = File.open path
						i.save
					end
				end
			end
		end
	end
	task product_clear_old_images: :environment do
		root = Rails.root.join('public').to_s
		Product.all.each do |p|
			if images = p.images
				images = images.split ','
				images.each do |image_path|
					path = root + image_path
					if File.exists? path
						File.delete path
					end
				end
			end
		end
	end
end
