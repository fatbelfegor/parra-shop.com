class Banner < ActiveRecord::Base
	before_destroy do |record|
		path = Rails.root.join('public').to_s + record.image
		File.delete path if File.exists? path
	end
end