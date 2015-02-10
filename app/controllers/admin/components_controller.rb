class Admin::ComponentsController < Admin::AdminController
	def index
		rend
	end
	def create
		case params[:name]
		when 'pages'
			seo_title = seo_description = seo_keywords = timestamps = false
			seo_title = true if params[:seo_title]
			seo_description = true if params[:seo_description]
			seo_keywords = true if params[:seo_keywords]
			timestamps = true if params[:timestamps]
			page = "\n\t\t@page = Page.find_by_scode params[:page]"
			page += "\n\t\t@seo_title = @page.seo_title" if seo_title
			page += "\n\t\t@seo_description = @page.seo_description" if seo_description
			page += "\n\t\t@seo_keywords = @page.seo_keywords" if seo_keywords
			Controller.create name: 'Pages', actions: {
				page: {
					code: page,
					view: "<%= raw @page.body %>"
				}
			}
			model = [
				{name: :name, type: :string},
				{name: :scode, type: :string, uniq: true},
				{name: :body, type: :text}
			]
			model << {name: :seo_title, type: :string} if seo_title
			model << {name: :seo_description, type: :string} if seo_description
			model << {name: :seo_keywords, type: :string} if seo_keywords
			timestamps ||= false
			Model.create name: 'Page', columns: model, timestamps: timestamps
			routes = Rails.root.join('config', 'routes.rb')
			File.write routes, File.read(routes).reverse.sub('end'.reverse, "\n\n\tget '/:page', to: 'pages#page'\nend".reverse).reverse
			`rake db:migrate`
		when 'images'
			File.write Rails.root.join('app', 'models', 'image.rb'), "class Image < ActiveRecord::Base\n\tbelongs_to :imageable, polymorphic: true\nend"
			path = Rails.root.join 'db', 'migrate'
			mirgation_name = "_create_images"
			i = Migration.index path, mirgation_name, '.rb'
			File.write Rails.root.join('db', 'migrate', "#{Time.now.strftime "%Y%m%d%H%M%S"}#{mirgation_name}#{i}.rb"), "class CreateImages < ActiveRecord::Migration\n\tdef change\n\t\tcreate_table :images do |t|\n\t\t\tt.string :name\n\t\t\tt.references :imageable, polymorphic: true, index: true\n\t\tend\n\tend\nend"
			`rake db:migrate`
		end
		rend
	end
end