class Banner < ActiveRecord::Base
	default_scope { order :position }
end
