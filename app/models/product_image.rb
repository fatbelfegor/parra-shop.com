class ProductImage < ActiveRecord::Base
	default_scope -> { order :position }
	mount_uploader :image, ProductImageUploader
end
