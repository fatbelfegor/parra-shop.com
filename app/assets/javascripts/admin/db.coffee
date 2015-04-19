@db =
	init: (array) ->
		for a in array
			@[a] =
				records: {}
				ready:
					all:
						full: false
						select: []
					where: {}
					where_null: {}
	save_one: (m, d) ->
		if d
			if d.record
				if d.belongs_to
					for k, v of d.belongs_to
						@save_one k, v
				if d.has_many
					d.ids ?= {}
					for k, v of d.has_many
						@[k].ready.where[m + '_id'] ?= []
						@[k].ready.where[m + '_id'].push d.record.id
						ids = []
						for r in v
							if r.id
								ids.push r.id
							else ids.push r.record.id
						d.ids[k] = ids
						@save_many k, v
				if d.ids
					for k, v of d.ids
						d.record[k + '_ids'] = v
				@[m].records[d.record.id] = d.record
			else if d.records
				if d.ids
					for k, v of d.ids
						for ids, i in v
							d.records[i][k + '_ids'] = ids
				if d.all
					if d.select
						for f in d.select
							@[m].ready.all.select.push f if f not in @[m].ready.all.select
					else
						@[m].ready.all.full = true
				for r in d.records
					r.select = d.select if d.select
					@save_one m, r
			else
				@[m].records[d.id] = d
	save_many: (m, d) ->
		if d
			for v in d
				@save_one m, v
		else
			for k, v of m
				@save_one k, v
	get: (params, cb) ->
		params = [params] unless params[0]
		check = (param) ->
			param.ready = false
			recs = []
			if param.find
				if param.find[0]
					for id in param.find
						rec = db[param.model].records[id]
						recs.push rec if rec
					param.ready = true if recs.length
				else
					rec = db[param.model].records[param.find]
					if rec
						recs = [rec]
						param.ready = true
						if param.select
							for f in select
								param.ready = false unless rec[f]
						else
							param.ready = false unless rec.full
			else if param.where or param.where_null
				ready_where = true
				for k, v of param.where
					if db[param.model].ready.where[k]
						if v[0]
							for i in v
								ready_where = false if i not in db[param.model].ready.where[k]
						else ready_where = false if v not in db[param.model].ready.where[k]
					else ready_where = false
				if param.where_null
					for f in param.where_null
						ready_where = false if f not in db[param.model].ready.where_null
				if ready_where
					where = param.where
					if param.where_null
						for k in param.where_null
							where[k] = null
					for id, rec of db[param.model].records
						push = true
						for k, v of where
							if v[0]
								push = false if rec[k] not in v
							else push = false unless rec[k] is v
						recs.push rec if push
					param.ready = true
			else
				if db[param.model].ready.all.full
					param.ready = true
				else if param.select
					param.ready = true
					for f in param.select
						param.ready = false if f not in db[param.model].ready.all.select
				if param.ready
					recs = db[param.model].records
			if param.belongs_to
				param.belongs_to = [param.belongs_to] unless param.belongs_to[0]
				for p, j in param.belongs_to
					if typeof p is 'string'
						param.belongs_to[j] = model: p
			if param.has_many
				param.has_many = [param.has_many] if typeof param.has_many is 'string'
				for p, j in param.has_many
					if typeof p is 'string'
						param.has_many[j] = model: p
			param.ids = [param.ids] if param.ids and typeof param.ids is 'string'
			if param.ready
				param_delete = true
				if param.belongs_to
					add_belongs_to = []
					for p, i in param.belongs_to
						param.belongs_to[i].find = []
						for rec in recs
							param.belongs_to[i].find.push rec[param.belongs_to[i].model + '_id']
						param.belongs_to[i] = check param.belongs_to[i]
						if param.belongs_to[i]
							param_delete = false
							add_belongs_to.push param.belongs_to[i]
					if add_belongs_to.length
						param.belongs_to = add_belongs_to
					else delete param.belongs_to
				if param.has_many
					ids = []
					ids.push rec.id for rec in recs
					add_has_many = []
					for p, i in param.has_many
						param.has_many[i].where ?= {}
						param.has_many[i].where[param.model + '_id'] = ids
						param.has_many[i] = check param.has_many[i]
						if param.has_many[i]
							param_delete = false
							delete param.has_many[i].where[param.model + '_id']
							delete param.has_many[i].where if $.isEmptyObject param.has_many[i].where
							add_has_many.push param.has_many[i]
					if add_has_many.length
						param.has_many = add_has_many
					else delete param.has_many
				if param.ids
					add_ids = []
					for k, i in param.ids
						for rec in recs
							add_ids.push k unless rec[k + '_ids']
					if add_ids.length
						param.ids = add_ids
						param_delete = false
					else delete param.ids
			else
				delete param.ready
				param_delete = false
			if param_delete
				false
			else param
		load_params = []
		for p, i in params
			params[i] = check p
			load_params.push params[i] if params[i]
		if load_params.length
			$.post '/admin/db/get', models: load_params, (r) ->
				get_relations = (m, recs, r) ->
					if m.belongs_to
						for k in m.belongs_to
							db.save_many k.model, r[m.model].belongs_to[k.model].records
					if m.has_many
						for k in m.has_many
							for rec in recs
								db[k.model].ready.where[m.model + '_id'] ?= []
								db[k.model].ready.where[m.model + '_id'].push rec.id
							db.save_many k.model, r[m.model].has_many[k.model].records
					if m.ids
						for f in m.ids
							for rec in recs
								db[m.model].records[rec.id][f + '_ids'] = r[m.model].ids[f][rec.id]
				for m in load_params
					recs = []
					if m.ready
						if m.belongs_to or m.has_many or m.ids
							recs = db.find m.model, m.find
					else
						recs = r[m.model].records
						recs.select = m.select if m.select
						db.save_many m.model, recs
					get_relations m, recs, r
				cb() if cb
			, 'json'
		else
			cb() if cb
	all: (model) ->
		ret = []
		ret.push rec for id, rec of db[model].records
		ret
	find: (model, find) ->
		return [] unless find
		find = [find] unless find[0]
		ret = []
		for f in find
			ret.push @[model].records[f]
		ret
	find_one: (model, find) -> @find(model, find)[0]
	where: (model, params) ->
		ret = []
		for id, rec of @[model].records
			push = true
			for k, v of params
				push = false if rec[k] != v
			ret.push rec if push
		ret
	images: (model, id) -> db.where "image", imageable_type: model, imageable_id: id
	destroy: (name, id, cb) ->
		$.post "/admin/model/#{name}/destroy/#{id}", {}, (res) ->
			if res is 'permission denied'
				notify 'Доступ запрещен', class: 'red'
			else
				delete db[name].records[id]
				notify 'Запись удалена'
				cb() if cb
		, 'json'
	save: (data, formData, params) ->
		params ?= {}
		$.ajax
			url: "/admin/db/save"
			data: formData
			type: 'POST'
			contentType: false
			processData: false
			dataType: "json"
			success: (res) ->
				if res is 'permission denied'
					notify 'Доступ запрещен', class: 'red'
				else
					go = (res, data) ->
						ret = {}
						for model_name, model_hash of res
							ret[model_name] = []
							for rec_index, rec of model_hash
								data_rec = data[model_name].rec[rec_index]
								save_rec = data_rec.fields
								if rec.image
									for k, v of rec.image
										save_rec[k] = v
								if rec.images
									for img in rec.images
										db.image.records[img.id] = img
								if rec.id
									ret[model_name].push rec.id
									save_rec.id = rec.id
									if rec.model
										ids = go rec.model, data_rec.model
										for sub_model_name, sub_model_ids of ids
											save_rec[sub_model_name + '_ids'] = sub_model_ids
									db[model_name].records[rec.id] = save_rec
								else
									if data_rec.removeImage
										for f in data_rec.removeImage
											save_rec[f] = ""
									if data_rec.removeImages
										for f in data_rec.removeImages
											delete db.image.records[f]
									for k, v of save_rec
										db[model_name].records[save_rec.id][k] = v
						ret
					go res, data
					for k, v of res
						if v[0].id
							app.go "/admin/model/#{k}/edit/#{v[0].id}", cb: -> notify 'Запись создана'
						else notify "Запись сохранена"
	create_one: (model, fields, cb) ->
		$.post "/admin/db/create_one", model: model, fields: fields, cb, 'json'
	update_one: (model, id, fields, cb) ->
		$.post "/admin/db/update_one", id: id, model: model, fields: fields, cb, 'json'
@db.init ['image', 'product', 'extension', 'category', 'subcategory', 'subcategory_item', 'size', 'color', 'texture', 'option', 'order', 'status', 'order_item', 'virtproduct', 'packinglist', 'packinglistitem', 'banner', 'user', 'user_log']