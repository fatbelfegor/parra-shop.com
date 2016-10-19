# encoding: utf-8

class ProductImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :verysmall do
    process resize_to_fit: [100, 100]
  end

  version :small do
    process resize_to_fit: [145, 145]
  end

  version :block do
    process resize_to_fit: [280, 280]
  end

  version :big do
    process resize_to_fit: [500, 500]
  end

end
