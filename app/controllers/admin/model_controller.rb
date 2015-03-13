class Admin::ModelController < Admin::AdminController

	def index
		rend
	end

	def new
		rend
	end

	def create
		name = params[:model].classify
		down = name.downcase
		Model.create name: name, columns: params[:addColumn], imageable: params[:imageable], timestamps: params[:timestamps], belongs_to: params[:belongs_to], has_one: params[:has_one], has_many: params[:has_many], acts_as_tree: params[:acts_as_tree]
		`rake db:migrate`
		Dir.mkdir Rails.root.join 'app', 'assets', 'javascripts', 'admin', 'models', down
		File.write Rails.root.join('app', 'assets', 'javascripts', 'admin', 'models', down, 'index.coffee'), params[:index]
		rend
	end

	def show
		rend
	end

	def edit
		name = params[:model]
		indexes = []
		columns = []
		for index in ActiveRecord::Base.connection.indexes(params[:model].pluralize.underscore)
			indexes << index.columns
		end
		for c in name.classify.constantize.columns
			columns << {name: c.name, type: c.type, limit: c.limit, precision: c.precision, scale: c.scale, default: c.default, null: c.null}
		end
		rend data: {
			model: {
				name => {
					columns: columns,
					indexes: indexes
				}
			}
		}
	end

	def update
		name = params[:model]
		classify = name.classify
		clasplur = classify.pluralize
		plur = name.pluralize
		model_path = Rails.root.join('app', 'models', name + '.rb')
		if params[:imageable]
			File.write model_path, File.read(model_path).sub("ActiveRecord::Base", "ActiveRecord::Base\n\thas_many :images, as: :imageable")
		end
		if params[:remove_imageable]
			File.write model_path, File.read(model_path).sub("\n\thas_many :images, as: :imageable", "")
		end
		path = Rails.root.join 'db', 'migrate'
		table_name = "_change_#{plur}"
		i = Migration.index path, table_name, '.rb'
		ret = ''
		remove = params[:remove]
		if remove
			for c in remove
				ret += "\n\t\tremove_column :#{plur}, :#{c}"
			end
		end
		File.write "#{path}/#{Time.now.strftime "%Y%m%d%H%M%S"}#{table_name}#{i}.rb", "class Change#{clasplur}#{i} < ActiveRecord::Migration\n\tdef change#{ret}\n\tend\nend" unless ret.blank?
		`rake db:migrate`
		rend
	end

	def destroy
		under = params[:model]
		plur = under.pluralize
		name = under.classify
		File.delete Rails.root.join 'app', 'models', "#{under}.rb"
		path = Rails.root.join 'db', 'migrate'
		table_name = "_drop_#{plur}_table"
		i = Migration.index path, table_name, '.rb'
		File.write "#{path}/#{Time.now.strftime "%Y%m%d%H%M%S"}#{table_name}#{i}.rb", "class Drop#{name.pluralize}Table#{i} < ActiveRecord::Migration\n\tdef up\n\t\tdrop_table :#{plur}\n\tend\n\t\n\tdef down\n\t\traise ActiveRecord::IrreversibleMigration\n\tend\nend"
		`rake db:migrate`
		rend
	end

	def habtm
		rend
	end

	def template_form
		rend
	end

	def template_index
		rend	
	end
end