class ImagesController < ApplicationController
  before_filter :admin_required
  layout false

  def new
  end

  def create
    if uploaded_io = params[:file]
      unless (File.exist?(Rails.root.join('public', 'uploads', uploaded_io.original_filename)))
        File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
      else
        index = 1
        while (File.exist?(Rails.root.join('public', 'uploads', index.to_s+uploaded_io.original_filename)))
          index += 1
        end
        File.open(Rails.root.join('public', 'uploads', index.to_s+uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
      end
      @url = '/uploads/'+index.to_s+uploaded_io.original_filename\
    end
  end

  def delete
    url = params[:url]    
    if url.include? request.env["HTTP_HOST"]
      url = Dir.pwd+'/public'+url.split(request.env["HTTP_HOST"])[1]
      File.delete url if File.exist? url
    else
      File.delete url if File.exist? url
    end
    if params[:cat].present? and params[:field].present?
      cat = Category.find params[:cat]
      cat.update params[:field] => (cat[params[:field]].split(',') - [url]).join(',')
    end
    if params[:product].present?
      product = Product.find params[:product]
      product.update images: (product.images.split(',') - [url]).join(',')
    end
    if params[:banner].present?
      banner = Banner.find params[:banner]
      banner.update image: (banner.image.split(',') - [url]).join(',')
    end
    render nothing: true
  end

end
