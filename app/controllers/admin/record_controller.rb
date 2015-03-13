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
		collect = {}
		for i, p in params[:models]
			name = p[:model].singularize
			model = name.classify.constantize
			records = true
			if p[:find]
				recs = model.find(p[:find])
				recs = [recs] unless recs.is_a? Array
			elsif p[:null] or p[:where]
				where = {}
				if p[:null]
					for f in p[:null]
						where[f] = nil
					end
				end
				if p[:where]
					for k, v in p[:where]
						where[k] = v
					end
				end
				recs = model.where(where)
			elsif p[:with]
				for i, h in p[:with]
					c = collect[h[:model]]
					if h[:where]
						where = {}
						for k, v in h[:where]
							where[k] = c[v]
						end
						recs = model.where where
					end
					if h[:find]
						c[h[:find]].compact!
						unless c[h[:find]].empty?
							recs = model.find c[h[:find]]
						end
					end
				end
			elsif p[:all]
				recs = model.all
			else
				records = false
			end
			data[name] = {}
			if records
				data[name][:model] = []
				for rec in recs
					data[name][:model] << rec.serializable_hash
				end
				if p[:ids]
					for h in p[:ids]
						n = h.singularize
						recs.each_with_index do |rec, i|
							data[name][:model][i][n + '_ids'] = rec.send(n + '_ids')
						end
					end
				end
			end
			if p[:collect]
				collect[name] = {}
				for f in p[:collect]
					if f == 'ids'
						collect[name]['ids'] = []
						for rec in data[name][:model]
							collect[name]['ids'] << rec['id']
						end
					else
						collect[name][f] = []
						for rec in data[name][:model]
							collect[name][f] << rec[f]
						end
					end
				end
			end
		end
		rend data: data
	end
end