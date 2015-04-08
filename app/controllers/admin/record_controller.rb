class Admin::RecordController < Admin::AdminController
	def new
		rend page: 'record/form'
	end

	def edit
		rend page: 'record/form'
	end

	def destroy
		return rend data: 'permission denied' if !role_records_all and !role_records_model params[:model]
		user_log :destroy, {model: params[:model]}, params[:model].classify.constantize.find(params[:id]).destroy
		rend
	end

	def save
		@permit_all = role_records_all
		@data = {relation: {}}
		def create_recursive rel, rel_id, parent_model, record_id
			if rel
				model_name = rel[:model]
				return rend(data: 'permission denied') if !@permit_all and !role_records_model model_name
				@data[:relation][rel_id] = {}
				if rel[:new_records]
					@data[:relation][rel_id][:new_records] = {}
					rel[:new_records].each_with_index do |rec, index|
						@data[:relation][rel_id][:new_records][index] = {}
						fields = rec[1][:fields]
						if rec[1][:image]
							@data[:relation][rel_id][:new_records][index][:image] = {}
							for field, image in rec[1][:image]
								fields[field] = '/images/' + save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)
								@data[:relation][rel_id][:new_records][index][:image][field] = fields[field]
							end
						end
						record = model_name.classify.constantize.new fields
						@data[:relation][rel_id][:new_records][index][:record] = {}
						unless rel_id == 0
							record[parent_model + '_id'] = record_id
							@data[:relation][rel_id][:new_records][index][:record][parent_model + '_id'] = record_id
						end
						if record.save
							user_log :create, {model: model_name}, record
							@data[:relation][rel_id][:new_records][index][:record][:id] = record.id
							if rec[1][:images]
								data_images = []
								for image in rec[1][:images]
									image = {url: '/images/' + save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)}
									image = record.images.create(image)
									data_images << image
								end
								@data[:relation][rel_id][:new_records][index][:images] = data_images
							end
							if params[:relations] and params[:relations][rel_id.to_s]
								for id in params[:relations][rel_id.to_s]
									create_recursive @relation[id], id.to_i, model_name, record.id
								end
							end
						end
					end
				end
				if rel[:update_records]
					@data[:relation][rel_id][:update_records] = {}
					rel[:update_records].each_with_index do |rec, index|
						@data[:relation][rel_id][:update_records][index] = {}
						fields = rec[1][:fields]
						record = model_name.classify.constantize.find(rec[1][:id])
						if rec[1][:removeImage]
							for field in rec[1][:removeImage]
								fields[field] = ""
								path = Rails.root.join('public').to_s + record[field]
								File.delete path if File.exists? path
							end
						end
						if rec[1][:image]
							@data[:relation][rel_id][:update_records][index][:image] = {}
							for field, image in rec[1][:image]
								fields[field] = '/images/' + save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)
								@data[:relation][rel_id][:update_records][index][:image][field] = fields[field]
							end
						end
						if record.update fields
							user_log :update, {model: model_name}, record
							if rec[1][:images]
								data_images = []
								for image in rec[1][:images]
									image = {url: '/images/' + save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)}
									image = record.images.create(image)
									data_images << image
								end
								@data[:relation][rel_id][:update_records][index][:images] = data_images
							end
							if rec[1][:removeImages]
								for id in rec[1][:removeImages]
									record.images.find(id).destroy
								end
							end
							if params[:relations] and params[:relations][rel_id.to_s]
								for id in params[:relations][rel_id.to_s]
									create_recursive @relation[id], id.to_i, model_name, record.id
								end
							end
						end
					end
				end
			end
		end
		@relation = params.require(:relation).permit!
		create_recursive @relation["0"], 0, nil, nil
		rend data: @data
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
		permit_all = role_records_all
		data = {}
		collect = {}
		for i, p in params[:models]
			name = p[:model].singularize
			return rend(data: 'permission denied') if !permit_all and !role_records_model name
			if p[:ready]
				if p[:collect]
					collect[name] = {}
					for f, v in p[:collect]
						collect[name][f] = v
					end
				end
				if p[:ids]
					model = name.classify.constantize
					recs = get_records model, p, collect
					data[name] = {}
					if !recs.empty?
						data[name][:ids] = {}
						for m_ids in p[:ids]
							data[name][:ids][m_ids] = {}
							for rec in recs
								data[name][:ids][m_ids][rec.id] = rec.send(m_ids + '_ids')
							end
						end
					end
				end
			else
				model = name.classify.constantize
				recs = get_records model, p, collect
				data[name] = {model: []}
				if !recs.empty?
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
								collect[name][f] << rec[f] unless rec[f] == 0
							end
						end
					end
				end
			end
		end
		rend data: data
	end

	def change
		model = params[:records][:name].classify.constantize
		if params[:records][:find]
			records = model.where(id: params[:records][:find])
		end
		records.update_all params[:change]
		rend
	end

	def copy
		records = {}
		def getRecs p, recs, parent
			recs.map do |r|
				ret = {}
				dup = r.dup
				if p[:set]
					for k, v in p[:set]
						dup[k] = v
					end
				end
				if parent
					dup[parent[:name] + '_id'] = parent[:id]
				end
				dup.save
				ret[:record] = dup
				if p[:has_many]
					ret[:has_many] = {}
					for i, v in p[:has_many]
						ret[:has_many][v[:name]] = getRecs(v, r.send(v[:name].pluralize), {name: p[:name], id: dup.id})
					end
				end
				ret
			end
		end
		for i, copy in params[:copy]
			records[copy[:name]] = getRecs(copy, copy[:name].classify.constantize.find(copy[:find]), false)
		end
		rend data: records
	end

	def editorimage
		image = params[:image]
		rend data: ('/images/' + save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image))
	end

private

	def get_records model, p, collect
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
					if c
						c[h[:find]].compact!
						if c[h[:find]] and !c[h[:find]].empty?
							recs = model.find c[h[:find]]
						else
							recs = []
						end
					else
						recs = []
					end
				end
			end
		elsif p[:all]
			recs = model.all
		else
			recs = []
		end
		recs
	end

end