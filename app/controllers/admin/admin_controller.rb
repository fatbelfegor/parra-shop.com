class Admin::AdminController < ApplicationController
	# before_filter :admin_required, except: [:welcome, :create_admin]
	before_filter :role_check
	before_filter :eager_load

	def home
		rend
	end

	def create_admin
		user = params[:user]
		User.create email: user[:email], password: user[:password], password_confirmation: user[:password_confirmation], confirmed_at: Time.now, role: 'admin' if User.count == 0
		redirect_to '/admin'
	end

	def write
		File.write Rails.root + params[:path], params[:file]
		rend
	end

	def checkuniq
		rend data: params[:model].classify.constantize.send("find_by_#{params[:field]}", params[:val]).nil?
	end

	def images_sort
		urls = params[:urls]
		params[:model].classify.constantize.find(params[:id]).images.each_with_index do |image, i|
			image.update url: urls[i]
		end
		rend
	end

protected

	def user_log action, req, object
		if @rules[:log] and @rules[:log][action]
			for r in @rules[:log][action]
				create = true
				for k, v in req
					create = false if !r[k] or r[k] != v
				end
				if create
					create = false if !r[:action] and !r[:type]
					if create
						user_log = {}
						if r[:action]
							user_log[:action] = r[:action].call(object)
						end
						current_user.user_logs.create user_log
					end
				end
			end
		end
	end

	def role_records_all
		if @rules[:all] then true else false end
	end

	def role_records_model name
		p name
		if @rules[:record]
			for r in @rules[:record]
				return true if r[:model] == name
			end
		end
		false
	end

	def role_check
		controller = params[:controller]
		action = params[:action]
		if current_user
			@rules = Admin::RoleList[current_user.role.to_sym]
			return if @rules[:all]
			route = @rules[controller + '#' + action]
			return redirect_to "/" if route == nil
			unless route == true
				for k, v in route
					if v.is_a? Array
						return redirect_to "/" unless v.include? params[k]
					else
						return redirect_to "/" unless params[k] == v
					end
				end
			end
		elsif action != 'welcome' and action != 'create_admin'
			redirect_to "/admin/welcome" unless current_user and current_user.role == 'admin'
		end
	end

	def file_index path, ending
		if File.exist? path + ending
			index = 1
			while File.exist? "#{path}#{index}#{ending}"
				index += 1
			end
			index.to_s
		else
			''
		end
	end

	def save_file path, name, file
		i = file_index path, name
		File.open path+i+name, 'wb' do |f|
			f.write file.read
		end
		i + name
	end

	def eager_load
		Rails.application.eager_load!
	end

	def rend *options
		if options and options != [] and options[0][:data]
			@data = options[0][:data]
		else
			@data = {}
		end
		respond_to do |format|
			if request.method == 'GET'
				format.html do
					Admin::AdminController.layout 'admin'
					render '/admin/all'
				end
			else
				format.json do
					render json: @data.to_json
				end
			end
		end
	end

	def migration_index path, name, rb
		i = 0
		name_with_i = name
		while !Dir["#{path}/*#{name_with_i}#{rb}"].empty?
			name_with_i = name + (i += 1).to_s
		end
		i = '' if i == 0
		i
	end

	class Controller
		def self.create options
			name = options[:name]
			under = name.underscore
			Dir.mkdir Rails.root.join 'app', 'views', under
			ret = "class #{name}Controller < ApplicationController"
			for action, hash in options[:actions]
				ret += "\n\tdef #{action}#{hash[:code]}\n\tend" if hash[:code]
				File.write Rails.root.join('app', 'views', under, "#{action}.html.erb"), hash[:view] if hash[:view]
			end
			ret += "\nend"
			File.write Rails.root.join('app', 'controllers', under + '_controller.rb'), ret
		end
	end

	class Model
		def self.create options
			Migration.create options
			name = options[:name]
			under = name.underscore
			plur = under.pluralize
			ret = "class #{name} < ActiveRecord::Base"
			ret += "\n\thas_many :images, as: :imageable" if options[:imageable]
			if options[:belongs_to]
				for hash in options[:belongs_to]
					ret += "\n\tbelongs_to :#{hash[:name].singularize.underscore}"
				end
			end
			if options[:has_one]
				for hash in options[:has_one]
					ret += "\n\thas_one :#{hash[:name].singularize.underscore}"
				end
			end
			if options[:has_many]
				for hash in options[:has_many]
					ret += "\n\thas_many :#{hash[:name].pluralize.underscore}"
				end
			end
			if options[:acts_as_tree]
				ret += "\n\thas_many :#{plur}\n\tbelongs_to :#{under}"
			end
			for column in options[:columns]
				ret += "\n\tvalidates :#{column[:name]}, uniqueness: true" if column[:uniq]
			end
			ret += "\nend"
			File.write Rails.root.join('app', 'models', "#{under}.rb"), ret
		end
	end

	class Migration
		def self.create options
			name = options[:name]
			plur = name.pluralize
			under = plur.underscore
			path = Rails.root.join 'db', 'migrate'
			mirgation_name = "_create_#{under}"
			i = index path, mirgation_name, '.rb'
			ret = "class Create#{plur}#{i} < ActiveRecord::Migration\n\tdef change\n\t\tcreate_table :#{under} do |t|"
			uniq = []
			for column in options[:columns]
				uniq << column[:name] if column[:uniq]
				ret += "\n\t\t\tt.#{column[:type].downcase} :#{column[:name].downcase}"
				ret += ", limit: #{column[:limit]}" if column[:limit] and column[:limit] != ''
				ret += ", precision: #{column[:precision]}" if column[:precision] and column[:precision] != ''
				ret += ", scale: #{column[:scale]}" if column[:scale] and column[:scale] != ''
				ret += ", default: '#{column[:default]}'" if column[:default] and column[:default] != ''
				ret += ", null: false" if !column[:null]
			end
			if options[:acts_as_tree]
				ret += "\n\t\t\tt.belongs_to :#{name.underscore}"
			end
			if options[:belongs_to]
				for hash in options[:belongs_to] 
					ret += "\n\t\t\tt.belongs_to :#{hash[:name].singularize.underscore}"
				end
			end
			ret += "\n\n\t\t\tt.timestamps null: false" if options[:timestamps]
			ret += "\n\t\tend"
			ret += "\n" unless uniq.empty?
			for u in uniq
				ret += "\n\t\tadd_index :#{under}, :#{u}, unique: true"
			end
			ret += "\n\tend\nend"
			File.write Rails.root.join('db', 'migrate', "#{Time.now.strftime "%Y%m%d%H%M%S"}#{mirgation_name}#{i}.rb"), ret
		end
		def self.has_and_belongs_to_many options, name
			path = Rails.root.join 'db', 'migrate'
			time = Time.now.strftime("%Y%m%d%H%M%S").to_i
			for hash in options
				connecting = hash[:name].classify
				unless connecting.constantize.reflect_on_all_associations(:has_and_belongs_to_many).map(&:name).include? name.pluralize.underscore.to_sym
					time += 1
					name1, name2 = [name, connecting].sort
					plur1 = name1.pluralize
					plur2 = name2.pluralize
					under1 = name1.underscore
					under2 = name2.underscore
					table = plur1.underscore + '_' + plur2.underscore
					mirgation_name = "_create_#{table}"
					i = index path, mirgation_name, '.rb'
					File.write "#{path}/#{time}#{mirgation_name}#{i}.rb", "class Create#{plur1}#{plur2} < ActiveRecord::Migration\n\tdef self.up\n\t\tcreate_table :#{table}, id: false do |t|\n\t\t\tt.references :#{under1}\n\t\t\tt.references :#{under2}\n\t\tend\n\n\t\tadd_index :#{table}, [:#{under1}_id, :#{under2}_id]\n\tend\n\n\tdef self.down\n\t\tdrop_table :#{table}\n\tend\nend"
				end
			end
		end
		def self.index path, name, rb
			i = 0
			name_with_i = name
			while !Dir["#{path}/*#{name_with_i}#{rb}"].empty?
				name_with_i = name + (i += 1).to_s
			end
			i = '' if i == 0
			i
		end
	end
end
