class Admin::DbController < Admin::AdminController
	def get
		permit_all = role_records_all
		@data = {}
		for i, p in params[:models]
			name = p[:model]
			return rend(data: 'permission denied') if !permit_all and !role_records_model name
			model = name.classify.constantize
			if p[:ready] and (p[:belongs_to] || p[:has_many] || p[:ids])
				recs = model.find(p[:find])
				recs = [recs] unless recs.is_a? Array
				@data[name] = {}
				get_relations p, recs, name, model
			else
				if p[:find]
					recs = model.find(p[:find])
					recs = [recs] unless recs.is_a? Array
				elsif p[:where] or p[:where_null]
					where = {}
					if p[:where]
						for k, v in p[:where]
							where[k] = v
						end
					end
					if p[:where_null]
						for f in p[:where_null]
							where[f] = nil
						end
					end
					recs = model.where(where)
				else
					recs = model.all
				end
				if p[:select]
					recs = recs.select(p[:select])
				end
				@data[name] = {records: recs}
				get_relations p, recs, name, model
			end
		end
		rend data: @data
	end
	def save
		@permit_all = role_records_all
		def go model, parent, parent_id
			data = {}
			for model_name, model_hash in model
				return rend(data: 'permission denied') if !@permit_all and !role_records_model model_name
				data[model_name] = {}
				model = model_name.classify.constantize
				for rec_index, rec in model_hash[:rec]
					data[model_name][rec_index] = {}
					if rec[:removeImage]
						for field in rec[:removeImage]
							rec[:fields][field] = ""
							path = Rails.root.join('public').to_s + record[field]
							File.delete path if File.exists? path
						end
					end
					if rec[:image]
						data[model_name][rec_index][:image] = {}
						for field, image in rec[:image]
							rec[:fields][field] = '/images/' + save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)
							data[model_name][rec_index][:image][field] = rec[:fields][field]
						end
					end
					if rec[:fields][:id]
						record = model.find(rec[:fields][:id])
						record.update(rec[:fields].except(:id))
						user_log :update, {model: model_name}, record
						if rec[:removeImages]
							for id in rec[:removeImages]
								record.images.find(id).destroy
							end
						end
						id = record.id
					else
						rec[:fields][parent] = parent_id unless parent_id.zero?
						record = model.create(rec[:fields])
						id = record.id
						user_log :create, {model: model_name}, record
						data[model_name][rec_index][:id] = id
					end
					if rec[:images]
						data_images = []
						for image in rec[:images]
							image = {url: '/images/' + save_file("#{Rails.root.join('public', 'images')}/", image.original_filename, image)}
							image = record.images.create(image)
							data_images << image
						end
						data[model_name][rec_index][:images] = data_images
					end
					if rec[:model]
						data[model_name][rec_index][:model] = go(rec[:model], model_name + '_id', id)
					end
				end
			end
			data
		end
		model = params.require(:model).permit!
		rend data: go(model, '', 0)
	end
	def create_one
		return rend(data: 'permission denied') if !(role_records_all or role_records_model params[:model])
		rec = params[:model].classify.constantize.create(params.require(:fields).permit!)
		user_log :create, {model: params[:model]}, rec
		rend data: rec.id
	end
	def update_one
		return rend(data: 'permission denied') if !(role_records_all or role_records_model params[:model])
		rec = params[:model].classify.constantize.find(params[:id])
		rec.update params.require(:fields).permit!
		user_log :update, {model: params[:model]}, rec
		rend data: true
	end
	def destroy
		return rend data: 'permission denied' if !(role_records_all or role_records_model params[:model])
		user_log :destroy, {model: params[:model]}, params[:model].classify.constantize.find(params[:id]).destroy
		rend
	end
private
	def get_relations p, recs, name, model
		if p[:belongs_to]
			@data[name][:belongs_to] = {}
			for i, m in p[:belongs_to]
				@data[name][:belongs_to][m[:model]] = {}
				if m[:find]
					@data[name][:belongs_to][m[:model]][:records] = m[:model].classify.constantize.find(m[:find])
				else
					@data[name][:belongs_to][m[:model]][:records] = []
					for rec in recs
						@data[name][:belongs_to][m[:model]][:records] << rec.send(m[:model])
					end
				end
			end
		end
		if p[:has_many]
			@data[name][:has_many] = {}
			for i, m in p[:has_many]
				@data[name][:has_many][m[:model]] = {} 
				@data[name][:has_many][m[:model]][:records] = []
				for rec in recs
					@data[name][:has_many][m[:model]][:records] += rec.send(m[:model].pluralize)
				end
			end
		end
		if p[:ids]
			@data[name][:ids] = {}
			for f in p[:ids]
				@data[name][:ids][f] = {}
				for rec in recs
					@data[name][:ids][f][rec.id] = rec.send(f + '_ids')
				end
			end
		end
	end
end