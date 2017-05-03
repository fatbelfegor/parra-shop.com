class Mailer < ActionMailer::Base

	def partner_request(params)
		@data = params
		mail(to: 'tsv169@gmail.com', subject: 'Заявка на сотрудничество.')
	end

	def order_project(params)
		@data = params
		mail(to: 'tsv169@gmail.com', subject: 'Заказ дизайн проекта.')
	end

	def order_credit(params)
		@data = params
		mail(to: 'tsv169@gmail.com', subject: 'Заказ кредита.')
	end

end