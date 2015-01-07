class Admin::ControllersController < Admin::AdminController
	def index
		controllers = {}
		Dir.entries(Rails.root.join('app', 'controllers')).select{|f| f.include? '.rb'}.sort.each{|f| controllers[f.sub('.rb', '')] = {}}
		rend page: 'controllers/index', data: {
			controllers: controllers
		}
	end
	def show
		controllers = {}
		Dir.entries(Rails.root.join('app', 'controllers')).select{|f| f.include? '.rb'}.sort.each do |frb|
			f = frb.sub('.rb', '')
			controllers[f] = {}
			if f == params[:contr]
				controllers[f][:code] = File.read Rails.root.join 'app', 'controllers', f + '.rb'
			end
		end
		rend page: 'controllers/show', data: {
			controllers: controllers
		}
	end
	def update
		File.write Rails.root.join('app', 'controllers', params[:contr] + '.rb'), params[:code]
		rend data: true
	end
	def action_create
		name = params[:name]
		contr = params[:contr]
		contr_name = contr.sub('_controller', '')
		act = "\n\n\tdef #{name}\n\tend\n"
		path = Rails.root.join('app', 'controllers', contr + '.rb')
		ret = File.read(path)
		if ret.include? "\nprivate"
			File.write path, ret.sub("\nprivate", "#{act}\nprivate")
		else
			File.write path, ret.reverse.sub("\nend".reverse, "#{act}\nend".reverse).reverse
		end
		if params[:view]
			File.write Rails.root.join('app', 'views', contr_name, "#{name}.html.erb"), "<h2>#{contr_name}##{name}</h2>"
		end
		if params[:root]
			path = Rails.root.join('config', 'routes.rb')
			File.write path, File.read(path).sub(/root to:.*/, '').sub("Rails.application.routes.draw do", "Rails.application.routes.draw do\n\n\troot to: '#{contr_name}##{name}'\n\n")
		end
		rend data: true
	end
end