class Admin::RecordController < Admin::AdminController

	def index
		p = Admin::Data[:index][params[:model].to_sym]
		unless p
			p = {}
		end
		model = params[:model].classify.constantize
		recs = model.all
		ret = {}
		if p[:order]
			recs = recs.order(p[:order])
			ret[:order] = p[:order]
		end
		if p[:where]
			recs = recs.where(p[:where])
			ret[:where] = p[:where]
		end
		if p[:count]
			ret[:count] = recs.count
		end
		if p[:select]
			recs = recs.select(p[:select] << :id)
			ret[:select] = p[:select]
		end
		if p[:offset]
			recs = recs.offset(p[:offset])
			ret[:offset] = p[:offset]
		end
		if p[:limit]
			recs = recs.limit(p[:limit])
			ret[:limit] = p[:limit]
		end
		if p[:ids]
			ret[:ids] = {}
			for id in p[:ids]
				ret[:ids][id] = recs.map {|r| r.send(id.to_s + '_ids')}
			end
		end
		if p[:belongs_to]
			ret[:belongs_to] = {}
			for bt in p[:belongs_to]
				ret[:belongs_to][bt] = recs.map {|r| r.send(bt)}
			end
		end
		if p[:has_many]
			ret[:has_many] = {}
			for hm in p[:has_many]
				ret[:has_many][hm] = recs.map {|r| r.send(hm.to_s.pluralize)}
			end
		end
		ret[:records] = recs
		data = {params[:model] => ret}
		rend data: data
	end

	def new
		r = {page: 'record/form'}
		model = params[:model].to_sym
		cb = Admin::Data[:new][model]
		r[:data] = cb.call(params) if cb
		rend r
	end

	def edit
		rend page: 'record/form', data: Admin::Data[:edit][params[:model].to_sym].call(params)
	end

	def change
		model = params[:records][:name].classify.constantize
		if params[:records][:find]
			records = model.where(id: params[:records][:find])
		end
		change = {}
		if params[:change]
			change = params.require(:change).permit!
		else
			change = {}
		end
		if params[:empty]
			empty = params.require(:empty)
			if empty.is_a? Array
				for f in empty
					change[f + '_ids'] = []
				end
			else
				change[empty + '_ids'] = []
			end
		end
		records.each {|r| r.update change}
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

	def sort_with_parent
		parent_id = params[:parent_id]
		parent_id = nil if parent_id == 'nil'
		name = params[:model]
		model = name.classify.constantize
		params[:ids].each_with_index do |id, index|
			model.find(id).update position: index+1, "#{name}_id" => parent_id
		end
		render :nothing => true
	end

	def sort_all
		model = params[:model].classify.constantize
		params[:ids].each_with_index do |id, index|
			model.find(id).update position: index+1
		end		
		render nothing: true
	end

end