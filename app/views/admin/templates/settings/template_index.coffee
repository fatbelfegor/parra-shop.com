@aceIds = 0
app.page = ->
	ret = "<h1 class='title'>Внешний вид вывода записей</h1>
	<div class='content'><br>"
	ret += "<div class='nav-tabs'>
		<p onclick='openTab(this)' class='active'>Общий вид</p>"
	for n of tables
		ret += "<p onclick='openTab(this)' class='capitalize'>#{n}</p>"
	ret += "</div><div class='tabs'>
		<div class='active'>
			<div class='btn green dashed' onclick='template.save(this, \"common\", true)'>Сохранить</div>
			<label class='group tags'>
				<p>Строковые поля</p>
				<div>
					<form onsubmit='return tag.add(this)' data-name='string'>"
	template = settings.template.index.common
	for c in template.string
		ret += "<div><i class='icon-close' onclick='rm(this)'></i><p data-val='#{c.name}' data-type='#{c.type}'>#{word c.name}</p></div>"
	ret += "<input type='text'>
						<input type='submit' class='hidden'>
					</form>
				</div>
			</label>
			<br>
			<label class='group tags'>
				<p>Текстовые поля</p>
				<div>
					<form onsubmit='return tag.add(this)' data-name='text'>"
	for name in template.text
		ret += "<div><i class='icon-close' onclick='rm(this)'></i><p data-val='#{c.name}' data-type='text'>#{word c.name}</p></div>"
	ret += "<input type='text'>
						<input type='submit' class='hidden'>
					</form>
				</div>
			</label>
		</div>"
	for k, table of tables
		ret += "<div>
				<div class='btn green dashed' onclick='template.save(this, \"#{k}\", false)'>Сохранить</div>"
		ret += tab.gen
			'Строчные поля': ->
				template = settings.template.index.model[k]
				template ||= {string: [], text: []}
				tabmodelfields = {}
				belongs_to = table.columns.filter (c) -> c.name[-3..-1] is "_id" and c.name isnt k + '_id'
				tabmodelfields[word k] = ->
					ret = "<div class='tag-container green'><h2>Поля этой модели</h2><div class='fields-sortable-string'>"
					ret += "<p data-val='#{c.name}' data-type='#{c.type}'>#{word c.name}</p>" for c in table.columns.filter (c) -> c.type isnt 'text' and c.name not in template.string
					ret + "</div></div>"
				for c in belongs_to
					cname = c.name[0..-4]
					belong_table = tables[cname]
					tabmodelfields[word cname] = ->
						served = []
						served.push n.name for n in template.string.filter((c) -> c.belongs_to is cname)
						ret = "<div class='tag-container green'><h2>Поля модели <b class='capitalize'>#{word cname}</b></h2><div class='fields-sortable-bt-string'>"
						ret += "<p data-val='#{c.name}' data-bt='#{cname}' data-type='#{c.type}'>#{word cname}: #{word c.name}</p>" for c in belong_table.columns.filter (c) -> c.type isnt 'text' and c.name not in served
						ret + "</div></div>"
				tabmodelfields['Кастомные поля'] = ->
					ret = "<div data-field='custom'>
						<div class='btn green' onclick='template.customField(this)'>Создать</div>
						<br><br>
						<label class='big'>
							<div>Заглавие</div>
							<input type='text' name='title'>
						</label>
						<br>
						<div class='ace-wrap'>
							<div id='ace-#{aceIds += 1}' class='editor'></div>
						</div>
						<br>
						<div class='tag-container green'>
							<h2>Созданные кастомные поля</h2>
							<div class='fields-sortable-custom'>
							</div>
						</div>
					</div>"
				ret = tab.gen tabmodelfields
				ret += "<br><div class='tag-container blue' data-name='string'><h2>Отображаются</h2><div class='fields-sortable-string fields-sortable-bt-string'>"
				for c in template.string
					if c.belongs_to
						ret += "<p data-val='#{c.name}' data-bt='#{c.belongs_to}' data-type='#{c.type}'>#{word c.belongs_to}: #{word c.name}</p>"
					else if c.custom
						ret += "<p data-custom='true' data-title='#{c.title}'><span class='hide'>#{c.cb}</span><i class='icon-close' onclick='rm(this)'></i><span>#{c.title}</span></p>"
					else
						ret += "<p data-val='#{c.name}' data-type='#{c.type}'>#{word c.name}</p>"
				ret + "</div></div>"
			'Текстовые поля': ->
				ret = "<div class='tag-container blue' data-name='text'><h2>Отображаются</h2><div class='fields-sortable-text'>"
				ret += "<p>#{c}</p>" for c in template.text
				ret += "</div></div><br>
						<div class='tag-container green'>
							<h2>Доступно</h2>
							<div class='fields-sortable-text'>"
				ret += "<p data-val='#{c.name}' data-type='text'>#{word c.name}</p>" for c in table.columns.filter (c) -> c.type is 'text' and c.name not in template.text
				ret += "</div></div>"
			'Предзагрузка': ->
				tab.gen 'has_many': ->
					ret = "<div data-name='has_many'>"
					for n in table.has_many
						checked = n in template.has_many if template.has_many
						ret += "<label class='checkbox'><div#{if checked then " class='checked'" else ''} data-val='#{n}'><input#{if checked then " checked='checked'" else ''} onchange='checkbox(this)' type='checkbox'></div>#{word n}</label><br>"
					ret += "</div>"
		ret += "</div>"
	ret += "</div><br></div><script src='/ace/ace.js'>"
	ret
@template = 
	save: (el, name, common) ->
		div = $(el).parent()
		data = {}
		data.path = "app/assets/javascripts/admin/settings/template_index_#{if common then "" else "model_"}#{name}.coffee"
		string = []
		div.find('[data-name=string] > div p').each ->
			el = $ @
			if el.data 'custom'
				string.push JSON.stringify {custom: true, title: el.data('title'), cb: el.find('.hide').html().replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"')}
			else
				bt = el.data 'bt'
				string.push "{name: '#{el.data 'val'}', type: '#{el.data 'type'}'#{if bt then ", belongs_to: '#{bt}'" else ''}}"
		text = []
		div.find('[data-name=text] > div p').each ->
			text.push "'#{$(@).data 'val'}'"
		has_many = []
		div.find('[data-name=has_many] > label > div').each ->
			el = $ @
			if el.hasClass 'checked'
				has_many.push "'#{el.data 'val'}'"
		data.file = "@settings.template.index.#{if common then "" else "model."}#{name} =\n\tstring: [#{string.join ','}]\n\ttext: [#{text.join ','}]#{if has_many.length > 0 then "\n\thas_many: [#{has_many.join ','}]" else ''}"
		act.sendData "write", data, "Вид вывода записей обновлен"
	customField: (el) ->
		wrap = $(el).parent()
		title = wrap.find("[name='title']").val()
		wrap.find('.fields-sortable-custom').append "<p data-custom='true' data-title='#{title}'><span class='hide'>#{ace.edit(wrap.find(".editor").attr 'id').getValue()}</span><i class='icon-close' onclick='rm(this)'></i><span>#{title}</span></p>"
		$('.fields-sortable-custom').sortable
			connectWith: ".fields-sortable-string"
app.after = ->
	$('.fields-sortable-bt-string').sortable
		connectWith: ".fields-sortable-bt-string"
	$('.fields-sortable-string').sortable
		connectWith: ".fields-sortable-string"
	$('.fields-sortable-text').sortable
		connectWith: ".fields-sortable-text"
	for i in [1..aceIds]
		editor = ace.edit "ace-" + i
		editor.getSession().setMode("ace/mode/javascript");
		editor.setValue("\"\"")