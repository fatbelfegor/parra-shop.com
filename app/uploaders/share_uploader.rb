class ShareUploader < CarrierWave::Uploader::Base
	include CarrierWave::MiniMagick
	storage :file

	def store_dir
		"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
	end

	version :medium do
		process resize_to_limit: [70, nil]
	end

	version :small do
		process resize_to_limit: [50, nil]
	end

end
