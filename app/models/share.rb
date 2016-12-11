class Share < ActiveRecord::Base
	mount_uploader :image, ShareUploader
end
