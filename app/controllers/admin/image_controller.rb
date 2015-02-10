class Admin::ImageController < Admin::AdminController

	def save
	    if image = params[:image]
	    	ret = save_file "#{Rails.root.join('public', 'images')}/", image.original_filename, image
		elsif images = params[:images]
			ret = []
			for image in images
				ret << save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)
			end
		end
		rend data: ret
	end

	def destroy
		if image = params[:image]
			url = Rails.root.to_s + '/public' + image
			File.delete url if File.exist? url
		end
		rend data: true
	end
	
end