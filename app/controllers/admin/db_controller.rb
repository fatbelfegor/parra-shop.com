class Admin::DbController < Admin::AdminController
	def get
		@data = {}
		if params[:models]
			for i, p in params[:models]
				@data[p[:model]] = get_records p
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
	def get_records p
		name = p[:model]
		model = name.classify.constantize
		ret = {}
		if p[:find]
			recs = model.where(id: p[:find])
		else
			if p[:where]
				recs = model.where(p[:where])
			else
				recs = model.all
			end
			if p[:order]
				recs = recs.order(p[:order])
			end
			if p[:offset]
				recs = recs.offset(p[:offset])
			end
			if p[:count]
				ret[:count] = recs.count
			end
			if p[:limit]
				recs = recs.limit(p[:limit])
			end
		end
		if p[:select]
			recs = recs.select(p[:select] << :id)
		end
		if p[:ids]
			recs = recs.map do |r|
				ids_ret = r.as_json
				for id in p[:ids]
					ids_ret[id + '_ids'] = r.send(id + '_ids')
				end
				ids_ret
			end
		end
		ret[:records] = recs
		if p[:belongs_to]
			ret[:belongs_to] = {}
			for i, a in p[:belongs_to]
				ids = recs.map{|r| r[a[:model] + '_id']}.compact
				if a[:find]
					a[:find] += ids
				else
					a[:find] = ids
				end
				ret[:belongs_to][a[:model]] = get_records a
			end
		end
		if p[:has_many]
			ret[:has_many] = {}
			for i, a in p[:has_many]
				ids = recs.map{|r| r[a[:model] + '_ids']}.reduce(:+)
				if a[:find]
					a[:find] += ids
				else
					a[:find] = ids
				end
				ret[:has_many][a[:model]] = get_records a
			end
		end
		ret
	end
end