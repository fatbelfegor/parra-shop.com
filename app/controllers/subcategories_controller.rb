class SubcategoriesController < ApplicationController
	before_filter :admin_required
	before_action :set_category, only: [:edit, :update, :destroy]

	def new
		@subcategory = Category.find(params[:id]).subcategories.new
	end

	def create
		@cat = Category.find(params[:id])
		@subcat = @cat.subcategories.create subcategory_params
		if !params[:images].blank?
			for image in params[:images]
				file = image[:file]
				sub_cat_image = {description: image[:description]}
				if file
					path = Rails.root.join('public', 'uploads')
					name = file.original_filename
					if File.exist? path + name
						index = 1
						while File.exist? path + '/' + index.to_s + name
							index += 1
						end
					else
						index = ''
					end
					File.open "#{path}/#{index}#{name}", 'wb' do |f|
						f.write file.read
			        end
			        sub_cat_image[:url] = "/uploads/#{index}#{name}"
			    end
			    @subcat.sub_cat_images.create sub_cat_image
			end
		end
		redirect_to @cat
	end

	def update
		@subcategory.update subcategory_params
		if !params[:images].blank?
			for image in params[:images]
				if image[:id].blank?
					file = image[:file]
					sub_cat_image = {description: image[:description]}
					if file
						path = Rails.root.join('public', 'uploads')
						name = file.original_filename
						if File.exist? path + '/' + name
							index = 1
							while File.exist? path + '/' + index.to_s + name
								index += 1
							end
						else
							index = ''
						end
						File.open "#{path}/#{index}#{name}", 'wb' do |f|
							f.write file.read
				        end
				        sub_cat_image[:url] = "/uploads/#{index}#{name}"
				    end
				    @subcategory.sub_cat_images.create sub_cat_image
				else
					scimage = SubCatImage.find(image[:id])
					if image[:destroy] == 'true'
						scimage.destroy
					end
					scimage.update description: image[:description]
					file = image[:file]
					sub_cat_image = {description: image[:description]}
					if file
						path = Rails.root.to_s + '/public'
						if !scimage.url.blank? and File.exist? path + scimage.url
							File.delete path + scimage.url
						end
						path += '/uploads'
						name = file.original_filename
						if File.exist? path + '/' + name
							index = 1
							while File.exist? path + '/' + index.to_s + name
								index += 1
							end
						else
							index = ''
						end
						File.open "#{path}/#{index}#{name}", 'wb' do |f|
							f.write file.read
				        end
				        scimage.update url: "/uploads/#{index}#{name}"
				    end
				end
			end
		end
		redirect_to @subcategory.category
	end

	def destroy
		@cat = @subcategory.category
		for image in @subcategory.sub_cat_images
			if !image.url.blank? and File.exist? image.url
				File.delete Rails.root.to_s + '/public' + image.url
			end
		end
		@subcategory.sub_cat_images.destroy_all
		@subcategory.destroy
		redirect_to @cat
	end

private
  def set_category
    @subcategory = Subcategory.find(params[:id])
  end
	def subcategory_params
		params.require(:subcategory).permit(
			:name,
			:description
		)
	end
end