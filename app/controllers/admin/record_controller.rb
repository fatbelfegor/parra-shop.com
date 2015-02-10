class Admin::RecordController < Admin::AdminController
	def new
		rend page: 'record/form'
	end

	def edit
		classify = params[:model].classify
		model = classify.constantize
		@records = {}
		rec = model.find(params[:id])
		@records[params[:model]] = {records: [rec]}
		if model.reflect_on_all_associations(:has_many).map(&:name).include? :images
			@records['image'] = {records: rec.images}
		end
		rend page: 'record/form'
	end

	def destroy
		params[:model].classify.constantize.find(params[:id]).destroy
		rend		
	end

	def create
		record = params[:model].classify.constantize.new params.require(:record).permit!
		if record.save
			if params[:images_urls]
				for url in params[:images_urls]
					record.images.create url: url
				end
			end
			id = record.id
		else
			id = nil
		end
		rend data: id
	end

	def update
		params[:model].classify.constantize.find(params[:id]).update params.require(:record).permit!
		rend
	end

	def index
		model = params[:model]
		model_const = model.classify.constantize
		rend page: 'record/index', data: {
			model: {
				params[:model] => {
					table: {
						columns: model.classify.constantize.columns						
					},
					has_many: model_const.reflect_on_all_associations(:has_many).map(&:name)
				}
			}
		}
	end

	def get
		data = {}
		for i, p in params[:models]
			name = p[:model]
			model = name.classify.constantize
			where = {}
			if p[:has_self_null]
				where["#{name}_id"] = nil
			end
			if p[:where]
				for k, v in p[:where]
					where[k] = v
				end
			end
			if p[:includes]
				data[name] = {records: model.includes(p[:includes]).where(where).limit(p[:limit]).offset(p[:offset])}
			else
				data[name] = {records: model.where(where).limit(p[:limit]).offset(p[:offset])}
			end
			if p[:has_self] or p[:has_many]
				ids = []
				for rec in data[name][:records]
					ids << rec.id
				end
			end
			if p[:has_self]
				data[name][:children] = []
				for rec in data[name][:records]
					data[name][:children] << model.where("#{name}_id" => rec.id).count
				end
			end
			if p[:has_many]
				data[name][:has_many] = {}
				for n in p[:has_many]
					data[name][:has_many][n.singularize] = n.classify.constantize.where("#{name}_id" => ids)
				end
			end
			if p[:belongs_to]
				data[name][:belongs_to] = {}
				for n in p[:belongs_to]
					bt_ids = []
					for rec in data[name][:records]
						bt_ids << rec.send("#{n}_id")
					end
					data[name][:belongs_to][n] = n.classify.constantize.find(bt_ids)
				end
			end
			if p[:habtm]
				data[name][:habtm] = {}
				for n in p[:habtm]
					data[name][:habtm][n] = []
					for rec in data[name][:records]
						data[name][:habtm][n] << rec.send(n + '_ids')
					end
				end
			end
		end
		rend data: data
	end
end