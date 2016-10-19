# encoding: utf-8

class ProductImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # version :small do
  #   process resize_to_fit: [50, 50]
  # end

  # version :block do
  #   process resize_to_fit: [180, 180]
  # end

  # version :big do
  #   process resize_to_fit: [300, 300]
  # end

end
