class ProductFooterImage < ActiveRecord::Base
	mount_uploader :image, ProductFooterImageUploader
end
