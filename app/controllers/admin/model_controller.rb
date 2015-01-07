class Admin::ModelController < Admin::AdminController

	def new
		rend page: 'model/new'
	end

	def create
		Model.create name: params[:model].classify, columns: params[:addColumn], timestamps: params[:timestamps], has_and_belongs_to_many: params[:has_and_belongs_to_many], acts_as_tree: params[:acts_as_tree]
		`rake db:migrate`
		rend data: true
	end

	def show
		render_all {}
	end

	def edit
		table_indexes = ActiveRecord::Base.connection.indexes(params[:model].pluralize.downcase)
		indexes = []
		for index in table_indexes
			indexes << index.columns
		end
		rend page: 'model/edit', data: {model: {params[:model] => {table: {columns: params[:model].capitalize.classify.constantize.columns, indexes: indexes}}}}
	end

	def update
		model = params[:model]
		models = model.pluralize.capitalize
		models_downcase = models.downcase
		rename = params[:rename]
		change = params[:change]
		remove = params[:remove]
		addColumn = params[:addColumn]

		path = Rails.root.join('db','migrate')
		name = "_change_#{models_downcase}"
		rb = ".rb"
		i = migration_index path, name, rb
		name_with_i = "#{name}#{i}"

		migration = "class Change#{models}#{i} < ActiveRecord::Migration\n\tdef change\n\t"
		if change
			for f in change
				changes = []
				changes << " :#{f[:type].downcase}"
				changes << " default: '#{f[:default]}'" if f[:default] != f[:old_default] and f[:default] != ''
				if f[:null]
					if f[:null] == 'on'
						f[:null] = 'true'
					else
						f[:null] = 'false'
					end
					changes << " null: '#{f[:null]}'" if f[:null] != f[:old_null]
				end
				if f[:limit] and f[:limit] != f[:old_limit]
					if f[:limit] == ''
						f[:limit] = nil
					end
					changes << " limit: #{f[:limit]}"
				end
				changes << " precision: #{f[:precision]}" if f[:precision] and f[:precision] != f[:precision] and f[:precision] != ''
				changes << " scale: #{f[:scale]}" if f[:scale] and f[:scale] != f[:scale] and f[:scale] != ''
			    migration += "\tchange_column :#{models_downcase}, :#{f[:name]},#{changes.join ','}\n\t" if changes != []
			end
		end
		if rename
			for f in rename
			    migration += "\trename_column :#{models_downcase}, :#{f[:old]}, :#{f[:new]}\n\t"
			end
		end
		if addColumn
			for f in addColumn
				migration += "\tadd_column :#{models_downcase}, :#{f[:name]}, :#{f[:type].downcase}"
				migration += ", limit: #{f[:limit]}" if f[:limit] and f[:limit] != ''
				migration += ", precision: #{f[:precision]}" if f[:precision] and f[:precision] != ''
				migration += ", scale: #{f[:scale]}" if f[:scale] and f[:scale] != ''
				migration += ", null: false" if f[:not_null]
				migration += ", default: '#{f[:default]}'" unless f[:default].blank?
				migration += "\n\t"
			end
		end
		if remove
			for f in remove
				migration += "\tremove_column :#{models_downcase}, :#{f}\n\t"
			end
		end
		migration += "end\nend"

		file = File.new("#{path}/#{Time.now.strftime "%Y%m%d%H%M%S"}#{name_with_i}#{rb}", "w+")
		file.puts(migration)
		file.close
		`rake db:migrate`
		rend data: true
	end

	def destroy
		name = params[:model]
		name_class = name.classify
		name_plurdown = name.pluralize
		habtm_array = name_class.constantize.reflect_on_all_associations(:has_and_belongs_to_many).map(&:name)
		path = Rails.root.join 'db', 'migrate'
		models_path = Rails.root.join 'app', 'models'
		mirgation_time_i = 0
		for model in habtm_array
			model = model.to_s
			model_path = models_path.join model.singularize + '.rb'
			File.write model_path, File.read(model_path).sub(/\thas_and_belongs_to_many :#{name_plurdown}\n/,'')
			first_model, second_model = [model, name_plurdown].sort
			drop_habtm_name = "_drop_#{first_model}_and_#{second_model}_table"
			drop_habtm_i = migration_index path, drop_habtm_name, '.rb'
			File.open("#{path}/#{(Time.now.strftime("%Y%m%d%H%M%S").to_i + (mirgation_time_i += 1)).to_s}#{drop_habtm_name}#{drop_habtm_i}.rb", "w+") {|f|
				f.puts "class Drop#{first_model.classify.pluralize}And#{second_model.classify.pluralize}Table#{drop_habtm_i} < ActiveRecord::Migration\n\tdef up\n\t\tdrop_table :#{first_model}_#{second_model}\n\tend\n\t\n\tdef down\n\t\traise ActiveRecord::IrreversibleMigration\n\tend\nend"
			}
		end
		drop_table_name = "_drop_#{name.pluralize.downcase}_table"
		drop_table_i = migration_index path, drop_table_name, '.rb'
		file = File.new(Rails.root.join('db','migrate',"#{Time.now.strftime "%Y%m%d%H%M%S"}#{drop_table_name}#{drop_table_i}.rb"), "w+")
		file.puts("class Drop#{name.pluralize.capitalize}Table#{drop_table_i} < ActiveRecord::Migration\n\tdef up\n\t\tdrop_table :#{name.pluralize}\n\tend\n\t\n\tdef down\n\t\traise ActiveRecord::IrreversibleMigration\n\tend\nend")
		file.close
		File.delete Rails.root.join 'app', 'models', "#{name}.rb"
		`rake db:migrate`
		rend data: true
	end
protected

	def habtm has_and_belongs_to_many, name, path, mirgation_time_i
		model_file = ''
		if has_and_belongs_to_many
			for f in has_and_belongs_to_many
				f_class = f.classify
				f_plurdown = f.pluralize.downcase
				model_file += "\thas_and_belongs_to_many :#{f_plurdown}\n"
				begin
					f_const = f_class.constantize
					if f_const.reflect_on_all_associations(:has_and_belongs_to_many).map(&:name).include? name.pluralize.downcase.to_sym
						create_habtm = false
					else
						create_habtm = true
						model_path = Rails.root.join('app', 'models', f_class.downcase + '.rb')
						File.write model_path, File.read(model_path).sub(/\n/, "\n\thas_and_belongs_to_many :#{name.pluralize.downcase}\n")
					end
				rescue
					create_habtm = true
				end
				if create_habtm
					first_model, second_model = [f_plurdown, name.pluralize.downcase].sort
					habtm_name = "_create_#{first_model}_and_#{second_model}"
					habtm_i = migration_index path, habtm_name, '.rb'
					file = File.new "#{path}/#{(Time.now.strftime("%Y%m%d%H%M%S").to_i + (mirgation_time_i += 1)).to_s}#{habtm_name}#{habtm_i}.rb", "w+"
					file.puts "class Create#{first_model.classify.pluralize}And#{second_model.classify.pluralize}#{habtm_i} < ActiveRecord::Migration\n\tdef change\n\t\tcreate_table :#{first_model}_#{second_model}, id: false do |t|\n\t\t\tt.belongs_to :#{first_model.singularize}, index: true\n\t\t\tt.belongs_to :#{second_model.singularize}, index: true\n\t\tend\n\tend\nend"
					file.close
				end
			end
		end
		model_file
	end

end