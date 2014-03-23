class ImagesController < ApplicationController

  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image }
    end
  end

  def create
    if uploaded_io = image_params[:url]
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
      image_params[:url] = '/uploads/'+index.to_s+uploaded_io.original_filename\
    end
    @image = Image.new(image_params)
  end

private

  def image_params
    params.require(:image).permit(:url)
  end
end
