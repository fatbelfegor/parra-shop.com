@db =
	init: (array) ->
		for a in array
			@[a] =
				records: {}
				ready:
					find:
						ids: []
						records: []
						select: []
					where:
						id:
							all:
								ids: []
								records:
									all: false
									positions: []
								select: []
	collect: (hash) ->
		for n, p of hash
			model = @[n]
			r = model.ready
			if p.count
				model.count = p.count
			if p.record
				if p.belongs_to
					for k, v of p.belongs_to
						if v
							if v.record is undefined
								v = record: v
							p.belongs_to[k] = v
						else
							delete p.belongs_to[k]
					@collect p.belongs_to
				if p.has_many
					p.ids ?= {}
					for k, v of p.has_many
						if v.length is 0
							delete p.has_many[k]
						else
							p.has_many[k] = records: v if v[0]
							hm_ids = p.has_many[k].records.map (rec) -> rec.id
							if p.ids[k]
								p.ids[k] = p.ids[k].concat hm_ids
							else p.ids[k] = hm_ids
					@collect p.has_many
				if p.ids
					for k, v of p.ids
						p.record[k + '_ids'] = v
					pids = []
					pids.push n for n of p.ids
					r.find.ids.push key: pids, records: [p.record.id]
				if p.select
					r.find.select.push key: p.select, records: p.record.id
				else
					r.find.records = [p.record.id]
				model.records[p.record.id] = p.record
			else
				ids = p.records.map (r) -> r.id
				if p.order
					p.order = [p.order] if typeof p.order is 'string'
					p.order = p.order.join()
					order = p.order
					r.where[order] =
						all:
							ids: []
							records:
								all: false
								positions: []
							select: []
				else order = 'id'
				if p.where
					where = []
					for k, v of p.where
						where.push k + ':' + v
						if v is null
							delete p.where[k]
							p.where_null ?= []
							p.where_null.push k
					where = where.sort().join()
					r.where[order][where] =
						ids: []
						records:
							all: false
							positions: []
						select: []
				else where = 'all'
				if p.belongs_to
					for k, v of p.belongs_to
						unless v.records
							v = records: v
						recs = []
						for rec in v.records
							if rec
								recs.push rec
						v.records = recs
						p.belongs_to[k] = v
					@collect p.belongs_to
				if p.has_many
					p.ids ?= {}
					for k, v of p.has_many
						if v[0]
							p.has_many[k] = records: v.reduce (a, b) -> a.concat b
							hm_ids = v.map (arr) -> arr.map (rec) -> rec.id
						else
							if v.records.length
								p.has_many[k].records = v.records.reduce (a, b) -> a.concat b
								hm_ids = v.records.map (arr) -> arr.map (rec) -> rec.id
						if hm_ids
							if p.ids[k]
								p.ids[k] = p.ids[k].concat hm_ids
							else p.ids[k] = hm_ids
					@collect p.has_many
				if p.ids
					for rec, i in p.records
						for k, v of p.ids
							rec[k + '_ids'] = v[i]
					pids = []
					pids.push n for n of p.ids
					r.find.ids.push key: pids, records: ids
					push = key: pids, records: {all: false, positions: []}
					push.records.all = true if !p.offset and !p.limit
					p.offset ?= 0
					if p.limit
						limit = p.offset + p.limit - 1
					else
						push.records.offset = p.offset
						limit = -1
					for i in [p.offset..limit]
						rec = p.records[i - p.offset]
						if rec
							push.records.positions[i] = rec.id
						else push.records.positions[i] = 0
					r.where[order][where].ids.push push
				if p.select
					r.find.select.push key: p.select, records: ids
					push = key: p.select, records: {all: false, positions: []}
					push.records.all = true if !p.offset and !p.limit
					p.offset ?= 0
					if p.limit
						limit = p.offset + p.limit - 1
					else
						push.records.offset = p.offset
						limit = -1
					for i in [p.offset..limit]
						rec = p.records[i - p.offset]
						if rec
							push.records.positions[i] = rec.id
						else push.records.positions[i] = 0
					r.where[order][where].select.push push
				else
					r.find.records = ids
					r.where[order][where].records.all = true if !p.offset and !p.limit
					p.offset ?= 0
					if p.limit
						limit = p.offset + p.limit - 1
					else
						r.where[order][where].records.offset = p.offset
						limit = -1
					for i in [p.offset..limit]
						rec = p.records[i - p.offset]
						if rec
							r.where[order][where].records.positions[i] = rec.id
						else r.where[order][where].records.positions[i] = 0
				model.records[rec.id] = rec for rec in p.records
	_get_ready: (r, p) ->
		if p.order
			p.order = [p.order] if typeof p.order is 'string'
			order_array = p.order
			p.order = p.order.join()
			order = p.order
			unless r.where[order]
				r.where[order] =
					all:
						ids: []
						records:
							all: false
							positions: []
						select: []
		else order = 'id'
		if p.where
			where = []
			for k, v of p.where
				where.push k + ':' + v
				if v is null
					delete p.where[k]
					p.where_null ?= []
					p.where_null.push k
			where = where.sort().join()
			unless r.where[order][where]
				r.where[order][where] =
					ids: []
					records:
						all: false
						positions: []
					select: []
		else where = 'all'
		r.where[order][where]
	_fill_where: (records, p, arr) ->
		records.all = true if !p.offset and !p.limit
		p.offset ?= 0
		if p.limit
			limit = p.offset + p.limit - 1
		else limit = -1
		for i in [p.offset..limit]
			rec = arr[i - p.offset]
			if rec
				records.positions[i] = rec.id
			else records.positions[i] = 0
	_find_in_ready: (ready_hash, find_array) ->
		records = false
		for a in ready_hash
			ok = true
			for b in find_array
				unless b in a.key
					ok = false
					break
			if ok
				records = a.records
				break
		records
	get: (params, cb) ->
		params = [params] unless params[0]
		string_to_array = (p) ->
			p.find = [p.find] if p.find and typeof p.find is 'number'
			p.ids = [p.ids] if p.ids and typeof p.ids is 'string'
			p.select = [p.select] if p.select and typeof p.select is 'string'
			p.order = [p.order] if p.order and typeof p.order is 'string'
			if p.belongs_to
				if typeof p.belongs_to is 'string'
					p.belongs_to = [model: p.belongs_to]
				else
					p.belongs_to = [p.belongs_to] unless p.belongs_to[0]
					for bt, i in p.belongs_to
						if typeof bt is 'string'
							p.belongs_to[i] = model: bt
				string_to_array bt for bt in p.belongs_to
			if p.has_many
				p.ids ?= []
				if typeof p.has_many is 'string'
					p.has_many = [model: p.has_many]
				else
					p.has_many = [p.has_many] unless p.has_many[0]
					for hm, i in p.has_many
						if typeof hm is 'string'
							p.has_many[i] = model: hm
				for hm in p.has_many
					p.ids.push hm.model unless hm.model in p.ids
					string_to_array hm
		for p in params
			string_to_array p
		find_analizer = (records, p) ->
			load = false
			for id in p.find
				unless id in records
					load = p
					break
			load
		where_analizer = (records, p) ->
			if records.all
				false
			else
				if p.offset or p.limit
					p.offset ?= 0
					if p.limit
						ret = false
						for i in [p.offset..p.offset + p.limit - 1]
							unless records.positions[i]
								ret = p
								break
						ret
					else
						if records.offset
							if records.offset > p.offset
								p.limit = records.offset - p.offset
								records.offset = p.offset
								p
							else false
						else p
				else p
		check = (p, model) ->
			r = db[model].ready
			load = false
			if p.find
				if p.ids
					records = db._find_in_ready r.find.ids, p.ids
					if records
						load = find_analizer records, p
					else
						r.find.ids.push key: p.ids, records: []
						load = p
				unless load
					records = r.find.records
					load = find_analizer records, p if records
				if p.select and load
					records = db._find_in_ready r.find.select, p.select
					if records
						load = find_analizer records, p
					else r.find.select.push key: p.select, records: []
			else
				r = db._get_ready r, p
				if p.ids
					records = db._find_in_ready r.ids, p.ids
					if records
						load = where_analizer records, p
					else
						r.ids.push key: p.ids, records: {all: false, positions: []}
						load = p
				unless load
					records = r.records
					load = where_analizer r.records, p
				if p.select and load
					records = db._find_in_ready r.select, p.select
					if records
						load = where_analizer records, p
					else r.select.push key: p.select, records: {all: false, positions: []}
			if !load
				if p.belongs_to or p.has_many
					if p.find
						recs = db.find model, records
					else
						recs = []
						recs.push r for id, r of db[model].records
						if p.order
							order = order_array.map((o) -> o).reverse()
							for o in order
								s = o.split ' '
								c = s[0]
								if s[1] and (s[1] is 'DESC' or s[1] is 'desc')
									recs.sort (a, b) ->
										if a[c] < b[c]
											1
										else if a[c] > b[c]
											-1
										else 0
								else
									recs.sort (a, b) ->
										if a[c] > b[c]
											1
										else if a[c] < b[c]
											-1
										else 0
						if p.offset and p.limit
							recs = recs[p.offset..p.offset + p.limit - 1]
						else if p.limit
							recs = recs[0..p.limit - 1]
						else if p.offset
							recs = recs[p.offset..-1]
					if p.belongs_to
						for bt in p.belongs_to
							ids = []
							for r in recs
								id = r[bt.model + '_id']
								ids.push id if id
							if ids.length
								bt.find = ids
								bt = check bt, bt.model
								load_params.push bt if bt
					if p.has_many
						for hm in p.has_many
							ids = []
							for r in recs
								id = r[hm.model + '_ids']
								ids = ids.concat id
							if ids.length
								hm.find = ids
								hm = check hm, hm.model
								load_params.push hm if hm
			load
		send_params = {}
		load_params = []
		for p, i in params
			model = p.model
			if model
				params[i] = check p, model
				load_params.push params[i] if params[i]
			else
				p.count = [p.count] if typeof p.count is 'string'
				ret = []
				for count in p.count
					unless db[count].count?
						ret.push count
				send_params.count = ret if ret.length
		len = load_params.length
		if len or send_params.count
			send_params.models = load_params if len
			$.post '/admin/db/get', send_params, (res) ->
				recursion_save = (p, res) ->
					db_records = db[p.model].records
					r = db[p.model].ready
					res_model = res[p.model]
					res_records = res_model.records
					if p.ids
						ids = db._find_in_ready r.find.ids, p.ids
						unless ids
							ids = []
							r.find.ids.push key: p.ids, records: ids
					if p.select
						select = db._find_in_ready r.find.select, p.select
						unless select
							select = []
							r.find.select.push key: p.select, records: select
					if p.ids and p.select
						for rec in res_records
							ids.push rec.id unless rec.id in ids
							select.push rec.id unless rec.id in select
							if db_records[rec.id]
								$.extend true, db_records[rec.id], rec
							else db_records[rec.id] = rec
						unless p.find
							r = db._get_ready r, p
							db._fill_where db._find_in_ready(r.ids, p.ids), p, res_records
							db._fill_where db._find_in_ready(r.select, p.select), p, res_records
					else if p.ids
						for rec in res_records
							ids.push rec.id unless rec.id in ids
							r.find.records.push rec.id
							if db_records[rec.id]
								$.extend true, db_records[rec.id], rec
							else db_records[rec.id] = rec
						unless p.find
							r = db._get_ready r, p
							db._fill_where db._find_in_ready(r.ids, p.ids), p, res_records
							db._fill_where r.records, p, res_records
					else if p.select
						for rec in res_records
							select.push rec.id unless rec.id in select
							if db_records[rec.id]
								$.extend true, db_records[rec.id], rec
							else db_records[rec.id] = rec
						unless p.find
							r = db._get_ready r, p
							db._fill_where db._find_in_ready(r.select, p.select), p, res_records
					else
						for rec in res_records
							r.find.records.push rec.id
							if db_records[rec.id]
								$.extend true, db_records[rec.id], rec
							else db_records[rec.id] = rec
						unless p.find
							r = db._get_ready r, p
							db._fill_where r.records, p, res_records
					if p.belongs_to
						for bt in p.belongs_to
							ids = []
							ids.push rec[bt.model + '_id'] for rec in res_records
							bt.find = ids
							recursion_save bt, res_model.belongs_to
					if p.has_many
						for hm in p.has_many
							if res_records.length
								hm.find = res_records.map((r) -> r[hm.model + '_ids']).reduce((a, b) -> a.concat b)
								recursion_save hm, res_model.has_many
				for p, i in load_params
					recursion_save p, res
				if send_params.count
					for k, v of res.count
						db[k].count = v
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
	select: (p) ->
		ids = []
		r = @_get_ready @[p.model].ready, p
		if p.ids
			records = @_find_in_ready(r.ids, p.ids).positions
		else if p.select
			records = @_find_in_ready(r.select, p.select).positions
		else records = r.records.positions
		p.offset ?= 0
		if p.limit
			limit = p.offset + p.limit - 1
		else limit = -1
		for i in [p.offset..limit]
			rec = records[i]
			ids.push rec if rec
		@find p.model, ids