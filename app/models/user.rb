class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

	has_many :manager_logs
    
	def admin?
		admin
	end

	def manager_log action, id
		if self.manager
			if id.is_a? Array
				log = {action: action, order_id: id[0], order_item_id: id[1], time: Time.now}
			else
				log = {action: action, order_id: id, time: Time.now}
			end
			self.manager_logs.create log
		end
	end
end
