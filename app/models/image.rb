class Image < ActiveRecord::Base
	belongs_to :imageable, polymorphic: true
	before_destroy do |record|
		path = Rails.root.join('public').to_s + record.url
		File.delete path if File.exists? path
	end
end