class Admin::RecordController < Admin::AdminController
	def new
		rend page: 'record/form'
	end

	def edit
		classify = params[:model].classify
		model = classify.constantize
		@records = {}
		id = params[:id].to_i
		rec = model.find(id)
		@records[params[:model]] = {records: [rec], full: {id: [id]}}
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
			data[p[:model]] = find p
		end
		rend data: data
	end

private
	def find p
		data = {}
		name = p[:model]
		model = name.classify.constantize
		if p[:load]
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
				data[:records] = model.includes(p[:includes]).where(where).limit(p[:limit]).offset(p[:offset])
			else
				data[:records] = model.where(where).limit(p[:limit]).offset(p[:offset])
			end
		end
		if p[:has_self] or p[:has_many]
			if p[:load]
				ids = data[:records].map{|r| r.id}
			else
				ids = p[:ids]
			end
		end
		if p[:has_self]
			data[name][:children] = []
			for rec in data[name][:records]
				data[name][:children] << model.where("#{name}_id" => rec.id).count
			end
		end
		if p[:has_many]
			data[:has_many] = {}
			for i, m in p[:has_many]
				m[:where] = {"#{name}_id" => ids}
				data[:has_many][m[:model]] = find m
			end
		end
		if p[:belongs_to]
			data[:belongs_to] = {}
			if p[:load]
				for i, m in p[:belongs_to]
					m[:where] = {id: data[:records].map{|r| r["#{m[:model]}_id"]}}
					data[:belongs_to][m[:model]] = find m
				end
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
		data
	end
end