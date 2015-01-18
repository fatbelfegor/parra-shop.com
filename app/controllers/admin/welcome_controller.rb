class Admin::WelcomeController < Admin::AdminController
	def welcome
		rend data: {authenticity_token: form_authenticity_token, users_count: User.count}
	end
end