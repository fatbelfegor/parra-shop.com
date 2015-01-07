class Admin::ImageController < Admin::AdminController
	def index
		render_all {}
	end

	def upload
		render_all {}
	end

	def save
	    if image = params[:image]
	    	ret = save_file "#{Rails.root.join('public', 'images')}/", image.original_filename, image
		elsif images = params[:images]
			ret = []
			for image in images
				ret << save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)
			end
		end
		render_all ret
	end

	def destroy
		if image = params[:image]
			url = Rails.root.to_s + '/public' + image
			File.delete url if File.exist? url
		end
		render_all true
	end
end