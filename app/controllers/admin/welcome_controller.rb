class Admin::WelcomeController < Admin::AdminController
	def welcome
		rend page: 'welcome/welcome', data: {authenticity_token: form_authenticity_token, users_count: User.count}
	end
end