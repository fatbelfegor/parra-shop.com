class Admin::RecordController < Admin::AdminController
	def new
		rend page: 'record/form'
	end

	def edit
		rend page: 'record/form', data: {
			record: params[:model].classify.constantize.find(params[:id])
		}
	end

	def create
		record = params[:model].classify.constantize.create params.require(:record).permit!
		if params[:images_urls]
			for url in params[:images_urls]
				record.images.create url: url
			end
		end
		rend data: record.id
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
		name = params[:model]
		model = name.classify.constantize
		where = {}
		if params[:has_self_null]
			where["#{name}_id"] = nil
		end
		if params[:where]
			for k, v in params[:where]
				where[k] = v
			end
		end
		data = {
			records: model.where(where).limit(params[:limit]).offset(params[:offset])
		}
		if params[:has_self]
			data[:children] = []
			for rec in data[:records]
				data[:children] << model.where("#{name}_id" => rec.id).count
			end
		end
		rend data: data
	end

	def destroy
		params[:model].classify.constantize.find(params[:id]).destroy
		rend data: true
	end
end